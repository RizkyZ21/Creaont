<?php

namespace App\Services;

use App\Models\Portfolio;
use Illuminate\Support\Collection;

class DesignerRecommendationService
{
    // ── Bobot total = 100 ────────────────────────────────────────────
    private const W_CATEGORY     = 25;  // kategori cocok
    private const W_BUDGET       = 20;  // harga dalam budget
    private const W_RATING       = 20;  // rating & jumlah ulasan
    private const W_EXPERIENCE   = 15;  // jumlah order selesai
    private const W_DEADLINE     = 12;  // estimasi hari pengerjaan
    private const W_KEYWORD      = 8;   // kecocokan brief

    public function recommend(array $criteria): Collection
    {
        $limit       = max(1, min((int) ($criteria['limit'] ?? 10), 30));
        $category    = trim((string) ($criteria['category'] ?? ''));
        $budget      = isset($criteria['budget']) ? (float) $criteria['budget'] : null;
        $deadlineDays = isset($criteria['deadline_days']) ? (int) $criteria['deadline_days'] : null;
        $keywords    = $this->extractKeywords((string) ($criteria['brief'] ?? ''));

        return Portfolio::with('user:id,name,bio,avatar')
            ->where('type', 'service')
            ->withCount('orders')
            ->withAvg('reviews', 'rating')
            ->withAvg('orders', 'estimated_days')
            ->get()
            ->map(fn (Portfolio $p) => $this->scorePortfolio($p, $category, $budget, $deadlineDays, $keywords))
            ->filter()
            ->sortByDesc('score')
            ->values()
            ->take($limit);
    }

    private function scorePortfolio(
        Portfolio $portfolio,
        string $category,
        ?float $budget,
        ?int $deadlineDays,
        array $keywords
    ): ?array {
        $breakdown = [];

        // ── 1. Kategori (25 poin) ────────────────────────────────────
        [$catScore, $catLabel] = $this->scoreCategory($portfolio->category, $category);
        $breakdown['category'] = ['score' => $catScore, 'max' => self::W_CATEGORY, 'label' => $catLabel];

        // ── 2. Budget (20 poin) — eliminasi jika jauh melebihi ───────
        [$budScore, $budLabel, $eliminate] = $this->scoreBudget($portfolio->price, $budget);
        if ($eliminate) return null;
        $breakdown['budget'] = ['score' => $budScore, 'max' => self::W_BUDGET, 'label' => $budLabel];

        // ── 3. Rating & ulasan (20 poin) ─────────────────────────────
        $rating = $portfolio->reviews_avg_rating !== null ? (float) $portfolio->reviews_avg_rating : null;
        [$ratingScore, $ratingLabel] = $this->scoreRating($rating);
        $breakdown['rating'] = ['score' => $ratingScore, 'max' => self::W_RATING, 'label' => $ratingLabel];

        // ── 4. Pengalaman / jumlah order (15 poin) ───────────────────
        $ordersCount = (int) ($portfolio->orders_count ?? 0);
        [$expScore, $expLabel] = $this->scoreExperience($ordersCount);
        $breakdown['experience'] = ['score' => $expScore, 'max' => self::W_EXPERIENCE, 'label' => $expLabel];

        // ── 5. Deadline / kecepatan (12 poin) ────────────────────────
        $avgDays = $portfolio->orders_avg_estimated_days !== null
            ? (float) $portfolio->orders_avg_estimated_days
            : null;
        [$dlScore, $dlLabel] = $this->scoreDeadline($avgDays, $deadlineDays);
        $breakdown['deadline'] = ['score' => $dlScore, 'max' => self::W_DEADLINE, 'label' => $dlLabel];

        // ── 6. Keyword brief (8 poin) ────────────────────────────────
        $matches = $this->countKeywordMatches($portfolio, $keywords);
        [$kwScore, $kwLabel] = $this->scoreKeywords($matches, count($keywords));
        $breakdown['keyword'] = ['score' => $kwScore, 'max' => self::W_KEYWORD, 'label' => $kwLabel];

        // ── Total skor ────────────────────────────────────────────────
        $totalScore = $catScore + $budScore + $ratingScore + $expScore + $dlScore + $kwScore;
        $totalScore = min(100, round($totalScore, 2));

        // ── Kumpulkan rules untuk tampilan ────────────────────────────
        $rules = array_map(
            fn ($k) => $breakdown[$k]['label'],
            array_keys($breakdown)
        );

        return [
            'score'            => $totalScore,
            'match_percentage' => (int) round($totalScore),
            'rules'            => $rules,
            'breakdown'        => $breakdown,
            'designer'         => $portfolio->user,
            'portfolio'        => $portfolio,
            'metrics'          => [
                'rating'            => $rating !== null ? round($rating, 1) : null,
                'orders_count'      => $ordersCount,
                'avg_estimated_days'=> $avgDays !== null ? round($avgDays, 1) : null,
            ],
        ];
    }

    // ── Aturan per kriteria ──────────────────────────────────────────

    private function scoreCategory(string $portfolioCategory, string $requestedCategory): array
    {
        if ($requestedCategory === '' || strtolower($requestedCategory) === 'all') {
            return [self::W_CATEGORY * 0.6, 'Tidak ada batasan kategori (' . self::W_CATEGORY . ' bobot).'];
        }
        if (strtolower($portfolioCategory) === strtolower($requestedCategory)) {
            return [self::W_CATEGORY, "Kategori \"$requestedCategory\" cocok sempurna."];
        }
        // Kategori mirip (sub-string check)
        $haystack = strtolower($portfolioCategory);
        $needle   = strtolower($requestedCategory);
        if (str_contains($haystack, $needle) || str_contains($needle, $haystack)) {
            return [self::W_CATEGORY * 0.55, "Kategori berhubungan dengan \"$requestedCategory\"."];
        }
        return [self::W_CATEGORY * 0.2, "Kategori berbeda dari \"$requestedCategory\"."];
    }

    private function scoreBudget(float $price, ?float $budget): array
    {
        if ($budget === null || $budget <= 0) {
            return [self::W_BUDGET * 0.5, 'Budget belum dibatasi.', false];
        }
        if ($price <= $budget) {
            $ratio = $price / $budget;
            if ($ratio <= 0.7) {
                return [self::W_BUDGET, 'Harga jauh di bawah budget — sangat hemat.', false];
            }
            return [self::W_BUDGET, 'Harga masuk dalam budget.', false];
        }
        $over = ($price - $budget) / $budget;
        if ($over <= 0.15) {
            return [self::W_BUDGET * 0.4, 'Harga sedikit di atas budget (≤15%).', false];
        }
        if ($over <= 0.30) {
            return [self::W_BUDGET * 0.15, 'Harga 15–30% di atas budget.', false];
        }
        // Lebih dari 30% di atas budget → eliminasi
        return [0, 'Harga jauh melebihi budget.', true];
    }

    private function scoreRating(?float $rating): array
    {
        if ($rating === null) {
            return [self::W_RATING * 0.3, 'Belum ada ulasan — designer baru.'];
        }
        if ($rating >= 4.8) return [self::W_RATING,            "Rating luar biasa ($rating★)."];
        if ($rating >= 4.5) return [self::W_RATING * 0.9,      "Rating sangat tinggi ($rating★)."];
        if ($rating >= 4.0) return [self::W_RATING * 0.75,     "Rating baik ($rating★)."];
        if ($rating >= 3.5) return [self::W_RATING * 0.55,     "Rating cukup ($rating★)."];
        return                    [self::W_RATING * 0.3,        "Rating masih rendah ($rating★)."];
    }

    private function scoreExperience(int $ordersCount): array
    {
        if ($ordersCount === 0) return [self::W_EXPERIENCE * 0.2, 'Jasa masih baru, belum ada order.'];
        if ($ordersCount >= 20)  return [self::W_EXPERIENCE,        "Sangat berpengalaman ($ordersCount order)."];
        if ($ordersCount >= 10)  return [self::W_EXPERIENCE * 0.8,  "Berpengalaman ($ordersCount order)."];
        if ($ordersCount >= 5)   return [self::W_EXPERIENCE * 0.6,  "Cukup berpengalaman ($ordersCount order)."];
        return                          [self::W_EXPERIENCE * 0.35,  "Pengalaman awal ($ordersCount order)."];
    }

    private function scoreDeadline(?float $avgDays, ?int $deadlineDays): array
    {
        if ($deadlineDays === null || $deadlineDays <= 0) {
            return [self::W_DEADLINE * 0.5, 'Deadline belum dibatasi.'];
        }
        if ($avgDays === null) {
            return [self::W_DEADLINE * 0.4, 'Estimasi hari pengerjaan belum tersedia.'];
        }
        if ($avgDays <= $deadlineDays * 0.7) {
            return [self::W_DEADLINE, "Estimasi pengerjaan jauh lebih cepat dari deadline ({$avgDays} hari)."];
        }
        if ($avgDays <= $deadlineDays) {
            return [self::W_DEADLINE * 0.85, "Estimasi pengerjaan masuk deadline ({$avgDays} hari)."];
        }
        if ($avgDays <= $deadlineDays + 3) {
            return [self::W_DEADLINE * 0.45, "Estimasi pengerjaan sedikit melewati deadline ({$avgDays} hari)."];
        }
        return [self::W_DEADLINE * 0.1, "Estimasi pengerjaan jauh melebihi deadline ({$avgDays} hari)."];
    }

    private function scoreKeywords(int $matches, int $totalKeywords): array
    {
        if ($totalKeywords === 0) {
            return [self::W_KEYWORD * 0.3, 'Tidak ada brief yang diisi.'];
        }
        if ($matches === 0) {
            return [0, 'Brief tidak cocok dengan jasa ini.'];
        }
        $ratio = $matches / $totalKeywords;
        $score = round(self::W_KEYWORD * min(1.0, $ratio * 1.2), 2);
        return [$score, "Brief cocok ($matches dari $totalKeywords kata kunci)."];
    }

    // ── Helpers ─────────────────────────────────────────────────────

    private function extractKeywords(string $brief): array
    {
        // Stopwords bahasa Indonesia umum
        static $stopwords = ['yang', 'dengan', 'untuk', 'dari', 'dalam', 'pada',
            'dan', 'atau', 'adalah', 'ini', 'itu', 'akan', 'bisa', 'saya',
            'kami', 'kita', 'mereka', 'juga', 'sudah', 'sudah', 'tidak'];

        $words = preg_split('/\s+/', strtolower($brief), -1, PREG_SPLIT_NO_EMPTY);

        return collect($words)
            ->map(fn (string $w) => trim($w, ".,!?;:()[]{}\"'"))
            ->filter(fn (string $w) => strlen($w) >= 3 && !in_array($w, $stopwords))
            ->unique()
            ->values()
            ->all();
    }

    private function countKeywordMatches(Portfolio $portfolio, array $keywords): int
    {
        if ($keywords === []) return 0;
        $haystack = strtolower(
            $portfolio->title . ' ' . $portfolio->description . ' ' . $portfolio->category
        );
        return collect($keywords)
            ->filter(fn (string $kw) => str_contains($haystack, $kw))
            ->count();
    }
}
