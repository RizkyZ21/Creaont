<?php

namespace App\Services;

use App\Models\Portfolio;
use Illuminate\Support\Collection;

class DesignerRecommendationService
{
    public function recommend(array $criteria): Collection
    {
        $limit = max(1, min((int) ($criteria['limit'] ?? 10), 30));
        $category = trim((string) ($criteria['category'] ?? ''));
        $budget = isset($criteria['budget']) ? (float) $criteria['budget'] : null;
        $deadlineDays = isset($criteria['deadline_days']) ? (int) $criteria['deadline_days'] : null;
        $keywords = $this->extractKeywords((string) ($criteria['brief'] ?? ''));

        return Portfolio::with('user:id,name,bio,avatar')
            ->where('type', 'service')
            ->withCount('orders')
            ->withAvg('reviews', 'rating')
            ->withAvg('orders', 'estimated_days')
            ->get()
            ->map(fn (Portfolio $portfolio) => $this->scorePortfolio(
                $portfolio,
                $category,
                $budget,
                $deadlineDays,
                $keywords
            ))
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
        $score = 0.0;
        $rules = [];

        $portfolioCategory = strtolower((string) $portfolio->category);
        if ($category !== '' && strtolower($category) !== 'all') {
            if ($portfolioCategory === strtolower($category)) {
                $score += 30;
                $rules[] = 'Kategori jasa sesuai kebutuhan.';
            } else {
                $score += 8;
                $rules[] = 'Kategori berbeda, tetapi masih bisa dipertimbangkan.';
            }
        } else {
            $score += 15;
            $rules[] = 'Tidak ada batasan kategori.';
        }

        if ($budget !== null && $budget > 0) {
            if ($portfolio->price <= $budget) {
                $score += 20;
                $rules[] = 'Harga masuk dalam budget.';
            } elseif ($portfolio->price <= $budget * 1.25) {
                $score += 8;
                $rules[] = 'Harga sedikit di atas budget.';
            } else {
                return null;
            }
        } else {
            $score += 10;
            $rules[] = 'Budget belum dibatasi.';
        }

        $avgEstimatedDays = $portfolio->orders_avg_estimated_days !== null
            ? (float) $portfolio->orders_avg_estimated_days
            : null;
        if ($deadlineDays !== null && $deadlineDays > 0) {
            if ($avgEstimatedDays === null || $avgEstimatedDays <= $deadlineDays) {
                $score += 15;
                $rules[] = 'Estimasi pengerjaan cocok dengan deadline.';
            } elseif ($avgEstimatedDays <= $deadlineDays + 3) {
                $score += 7;
                $rules[] = 'Estimasi pengerjaan mendekati deadline.';
            } else {
                $score += 2;
                $rules[] = 'Deadline cukup ketat untuk riwayat pengerjaan designer.';
            }
        } else {
            $score += 8;
            $rules[] = 'Deadline belum dibatasi.';
        }

        $rating = $portfolio->reviews_avg_rating !== null
            ? (float) $portfolio->reviews_avg_rating
            : 0.0;
        if ($rating >= 4.5) {
            $score += 20;
            $rules[] = 'Rating designer sangat tinggi.';
        } elseif ($rating >= 4.0) {
            $score += 16;
            $rules[] = 'Rating designer baik.';
        } elseif ($rating > 0) {
            $score += 10;
            $rules[] = 'Designer sudah memiliki ulasan.';
        } else {
            $score += 6;
            $rules[] = 'Designer belum memiliki banyak ulasan.';
        }

        $ordersCount = (int) ($portfolio->orders_count ?? 0);
        $score += min(10, $ordersCount * 2);
        if ($ordersCount > 0) {
            $rules[] = "Sudah menangani {$ordersCount} order pada jasa ini.";
        } else {
            $rules[] = 'Jasa masih baru, cocok untuk mencoba designer baru.';
        }

        $keywordMatches = $this->countKeywordMatches($portfolio, $keywords);
        if ($keywordMatches > 0) {
            $score += min(10, $keywordMatches * 3);
            $rules[] = 'Brief cocok dengan judul/deskripsi jasa.';
        }

        $score = min(100, round($score, 2));

        return [
            'score' => $score,
            'match_percentage' => (int) round($score),
            'rules' => $rules,
            'designer' => $portfolio->user,
            'portfolio' => $portfolio,
            'metrics' => [
                'rating' => $rating > 0 ? round($rating, 1) : null,
                'orders_count' => $ordersCount,
                'avg_estimated_days' => $avgEstimatedDays !== null ? round($avgEstimatedDays, 1) : null,
            ],
        ];
    }

    private function extractKeywords(string $brief): array
    {
        $words = preg_split('/\s+/', strtolower($brief), -1, PREG_SPLIT_NO_EMPTY);

        return collect($words)
            ->map(fn (string $word) => trim($word, ".,!?;:()[]{}\"'"))
            ->filter(fn (string $word) => strlen($word) >= 4)
            ->unique()
            ->values()
            ->all();
    }

    private function countKeywordMatches(Portfolio $portfolio, array $keywords): int
    {
        if ($keywords === []) {
            return 0;
        }

        $haystack = strtolower($portfolio->title . ' ' . $portfolio->description . ' ' . $portfolio->category);

        return collect($keywords)
            ->filter(fn (string $keyword) => str_contains($haystack, $keyword))
            ->count();
    }
}
