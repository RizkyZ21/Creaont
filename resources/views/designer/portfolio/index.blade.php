<a href="/designer/portfolio/create">+ Tambah</a>

@foreach($portfolios as $p)
    <div>
        <h3>{{ $p->title }}</h3>

        <a href="/designer/portfolio/{{ $p->id }}/edit">Edit</a>
    </div>
@endforeach
