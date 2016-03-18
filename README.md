# Gallry

Simple image gallery written with Perl/Mojolicious. See it in action at
[http://gallry.markusko.ch](http://gallry.markusko.ch)

## Dependencies

* Perl
* Mojolicious

## Installation

Simply clone or download the the repository, adjust the gallry.conf file and
execute either:

    $ morbo script/gallry (for development), or
    $ hypnotoad -f script/gallry (for production)

## Documentation

### Password protection

To password protect a gallery, first create the sha512 hash of the desired
password with:

  

Then copy that value to the `.config.json` of the gallery:

    {
        "title": "Gallery Title",
        "date": "2015-01-01",
        "author": "Gallery Author",
        "pwhash": "a596946f ... 55097cd5ee56f3"
    }

### ZIP download

To offer a ZIP download of all images in one gallery, simply create a ZIP archive
containing all images, e.g.

    $ cd galleries/ExampleGallery/images
    $ zip ../images.zip *.jpg

The ZIP file must be called `images.zip` and be stored at
`galleries/ExampleGallery/`.
