<h1>Explore Design</h1>

@foreach($portfolios as $p)
    <div>
        <h3>{{ $p->title }}</h3>
        <p>{{ $p->description }}</p>
        <p>Rp {{ $p->price }}</p>
    </div>
@endforeach