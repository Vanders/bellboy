Bellboy
======
Manage data bags and data bag items alongside Berkshelf.

Installation
------------
Add Bellboy to your repository's `Gemfile`:

```ruby
gem 'bellboy'
```

Or run it as a standalone:

    gem install bellboy

Usage
-----
Bellboy is intended to be used alongside Berkshelf, allowing Berkshelf to manage the cookbooks and their dependencies and Bellboy to manage Databags & Databag Items that are associated with each cookbook.

Bellboy can be used to version databag items (created from databag templates), upload the databags to a server, and download databags via. an API server in a similar way to Berkshelf.

Bellboy expects databags to be stored within the cookbook in a directory named `data_bags`. It will search this directory for databags, and then for databag items (and databag item templates) within each databag.

### Versioning databags

Simply run Bellboy from the cookbook directory which contains the data bags:

    bellboy version

Bellboy will obtain the current cookbook version information using `Thor-scmversion` and apply this version data to any databag item templates it finds.

Please see the documentation for [knife-databag-version](https://rubygems.org/gems/knife-data-bag-version) for more information on databag versioning.

### Installing databags

    bellboy install

If any cookbooks held in the current Berkshelf cookbook cache have a `Bellboy` file then Bellboy will download all of the databags and databag items that are specified.

Databags & databag items are stored within a directory named `data_bags` within each cookbook in the Berkshelf cache. Subsequently running Bellboy to upload databags will upload any databags & databag items that were downloaded by Bellboy.

### Uploading databags

    bellboy upload

Bellboy creates the databags on the remote server, uploads all databag items (files ending in `.json` that are found below the `data_bags` directory) and create the `Bellboy` file which tells Bellboy which databag items are associated with this cookbook.

Once you have uploaded the databags you can run `berks upload`. This ensures that Berkshelf uploads the `Bellboy` file along with the cookbook.

Examples
--------
### Uploading databags

Assume the following cookbook:

    myface/
	    recipes/
			default.rb
		metadata.rb
		LICENSE
		README.md
		Berksfile
		Thorfile
		.gitignore

We add our databags within the cookbook

	myface
		...
		data_bags/
			myface/
				data.json
				versioned_data.erb

Using Bellboy we run `bellboy version` to create versioned databag items:

	$ cd myface
	$ bellboy version
	Templating data bag item ./data_bags/myface/versioned_data

This will create a new JSON file:

	myface/
		...
		data_bags/
			myface/
				data.json
				versioned_data.erb
				versioned_data_1_2_0.json

Now we can use Bellboy to upload the databag items to the Chef server:

	$ bellboy upload
	Uploading ./data_bags/myface/versioned_data_1_2_0.json

Bellboy will create the `Bellboy` file for us. When we upload the cookbook with Berkshelf, the `Bellboy` file will be uploaded.

### Downloading databags

We download the cookbooks in the usual way with Berkshelf:

	$ berks install
	Installing myface (1.2.0) from site: 'https://example.com'

Berkshelf will download the `Bellboy` file as part of the cookbook and store it in its cookbook cache. We can use Bellboy to retrieve the databags:

	$ bellboy install
	Downloading databags for myface-1.2.0
	Downloading data bag item myface/versioned_data_1_2_0 from 'https://example.com/databags/myface/versioned_data_1_2_0'

Configuration
-------------
Bellboy will use the same configuration locations as Berkshelf. These are:

```text
$PWD/.berkshelf/config.json
$PWD/berkshelf/config.json
$PWD/berkshelf-config.json
$PWD/config.json
~/.berkshelf/config.json
```

You can also specify the path to the Berkshelf configuration file with the ```-c``` option:

    bellboy install -c /path/to/berkshelf/config.json

### Databags API

Bellboy requires a working API server which it uses to download databag items. Normally Bellboy expects this API to run alongside your existing Berkshelf API, and Bellboy will use the existing `site` directive from the Berksfile to find the API.

For example, if your Berksfile contains

    site "https://example.com"

then Bellboy assumes that the databag API is running at `https://example.com/databags`

It is also possible to run the databag API at a different location. You can specify the URL to the API with the Bellboy specific `databags` directive in your Berksfile. However, Berkshelf will not understand this directive, so using `databags` in your Berksfile is slightly more complicated

    site "https://example.com"
    databags "https://databags.example.com" if Object.constants.include? :Bellboy

The `if` clause ensures that Berkshelf will ignore the new directive, but that it will be processed if the Berksfile is loaded by Bellboy.

The databag API is a simple Sinatra application. See [the Githib page](https://github.com/dyninc/databagapi) for the source and documentation.