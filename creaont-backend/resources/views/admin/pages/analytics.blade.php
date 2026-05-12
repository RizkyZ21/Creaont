@extends('admin.layouts.app')

@section('page-title', 'Analytics & Reports')

@section('extra-css')
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.js"></script>
@endsection

@section('content')
<div class="row mb-4">
    <div class="col-md-6">
        <div class="table-container">
            <div style="padding: 20px; border-bottom: 1px solid #e2e8f0;">
                <h5 style="margin: 0; color: var(--primary);">Orders by Month</h5>
            </div>
            <div style="padding: 20px; position: relative; height: 300px;">
                <canvas id="ordersChart"></canvas>
            </div>
        </div>
    </div>
    <div class="col-md-6">
        <div class="table-container">
            <div style="padding: 20px; border-bottom: 1px solid #e2e8f0;">
                <h5 style="margin: 0; color: var(--primary);">Revenue by Month</h5>
            </div>
            <div style="padding: 20px; position: relative; height: 300px;">
                <canvas id="revenueChart"></canvas>
            </div>
        </div>
    </div>
</div>

<div class="row">
    <div class="col-12">
        <div class="table-container">
            <div style="padding: 20px; border-bottom: 1px solid #e2e8f0;">
                <h5 style="margin: 0; color: var(--primary);">
                    <i class="fas fa-chart-bar"></i> Top 10 Designers
                </h5>
            </div>
            <table class="table">
                <thead>
                    <tr>
                        <th>Rank</th>
                        <th>Designer</th>
                        <th>Total Orders</th>
                        <th>Total Revenue</th>
                        <th>Avg per Order</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse ($designers_top as $key => $designer)
                        <tr>
                            <td><strong>{{ $key + 1 }}</strong></td>
                            <td>{{ $designer->designer->name }}</td>
                            <td>
                                <span class="badge bg-info">{{ $designer->orders_count }}</span>
                            </td>
                            <td><strong>Rp {{ number_format($designer->revenue, 0, ',', '.') }}</strong></td>
                            <td>Rp {{ number_format($designer->revenue / $designer->orders_count, 0, ',', '.') }}</td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="5" class="text-center text-muted py-4">
                                No data available
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>
</div>

@section('extra-js')
<script>
    // Orders Chart
    var ordersCtx = document.getElementById('ordersChart').getContext('2d');
    var ordersChart = new Chart(ordersCtx, {
        type: 'line',
        data: {
            labels: @json($orders_by_month->pluck('month')->map(fn($m) => 'Month ' . $m)->toArray()),
            datasets: [{
                label: 'Orders',
                data: @json($orders_by_month->pluck('count')->toArray()),
                borderColor: '#6366f1',
                backgroundColor: 'rgba(99, 102, 241, 0.1)',
                tension: 0.4,
                fill: true
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    display: false
                }
            },
            scales: {
                y: {
                    beginAtZero: true
                }
            }
        }
    });

    // Revenue Chart
    var revenueCtx = document.getElementById('revenueChart').getContext('2d');
    var revenueChart = new Chart(revenueCtx, {
        type: 'bar',
        data: {
            labels: @json($revenue_by_month->pluck('month')->map(fn($m) => 'Month ' . $m)->toArray()),
            datasets: [{
                label: 'Revenue (Rp)',
                data: @json($revenue_by_month->pluck('total')->toArray()),
                backgroundColor: '#8b5cf6',
                borderRadius: 5
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    display: false
                }
            },
            scales: {
                y: {
                    beginAtZero: true
                }
            }
        }
    });
</script>
@endsection
@endsection
