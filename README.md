Busboy
======
Manage data bags and data bag items alongside Berkshelf.

Installation
------------
Add Busboy to your repository's `Gemfile`:

```ruby
gem 'busboy'
```

Or run it as a standalone:

    gem install busboy

Usage
-----
Busboy is intended to be used alongside Berkshelf, allowing Berkshelf to manage the Cookbooks and their dependencies and Busboy to manage Databags & Databag Items that are associated with each Cookbook.

Busboy can be used to version databag items (created from databag templates), upload the databags to a server, and download databags via. an API server in a similar way to Berkshelf.

Busboy expects databags to be stored within the Cookbook in a directory named `data_bags`. It will search this directory for databags, and then for databag items (and databag item templates) within each databag.

### Versioning databags

Simply run Busboy from the Cookbook directory which contains the data bags:

    busboy version

Busboy will obtain the current cookbook version information using `Thor-scmversion` and apply this version data to any databag item templates it finds.

Please see the documentation for [knife-databag-version](https://rubygems.org/gems/knife-data-bag-version) for more information on databag versioning.

### Installing databags

    busboy install

If any Cookbooks held in the current Berkshelf cookbook cache have a `Busboy` file then Busboy will download all of the databags and databag items that are specified.

Databags & databag items are stored within a directory named `data_bags` within each Cookbook in the Berkshelf cache. Sebseuntly running Busboy to upload databags will upload any databags & databag items that were downloaded by Busboy.

### Uploading databags

    busboy upload

Busboy creates the databags on the remote server, uploads all databag items (files ending in `.json` that are found below the `data_bags` directory) and create the `Busboy` file which tells Busboy which databag items are associated with this Cookbook.

Once you have uploaded the databags you can run `berks upload`. This ensures that Berkshelf uploads the `Busboy` file along with the Cookbook.

Examples
--------
### Uploading databags

Assume the following Cookbook:

    myface/
	    recipes/
			default.rb
		metadata.rb
		LICENSE
		README.md
		Berksfile
		Thorfile
		.gitignore

We add our databags within the Cookbook

	myface
		...
		data_bags/
			myface/
				data.json
				versioned_data.erb

Using Busboy we run `busboy version` to create versioned databag items:

	$ cd myface
	$ busboy version
	Templating data bag item ./data_bags/myface/versioned_data

This will create a new JSON file:

	myface/
		...
		data_bags/
			myface/
				data.json
				versioned_data.erb
				versioned_data_1_2_0.json

Now we can use Busboy to upload the databag items to the Chef server:

	$ busboy upload
	Uploading ./data_bags/myface/versioned_data_1_2_0.json

Busboy will create the `Busboy` file for us. When we upload the Cookbook with Berkshelf, the `Busboy` file will be uploaded.

### Downloading databags

We download the Cookbooks in the usual way with Berkshelf:

	$ berks install
	Installing myface (1.2.0) from site: 'https://example.com'

Berkshelf will download the `Busboy` file as part of the Cookbook and store it in it's Cookbook cache. We can use Busboy to retrieve the databags:

	$ busboy install
	Downloading databags for myface-1.2.0
	Downloading data bag item myface/versioned_data_1_2_0 from 'https://example.com/databags/myface/versioned_data_1_2_0'

Configuration
-------------
Busboy will use the same configuration locations as Berkshelf. These are:

```text
$PWD/.berkshelf/config.json
$PWD/berkshelf/config.json
$PWD/berkshelf-config.json
$PWD/config.json
~/.berkshelf/config.json
```

You can also specify the path to the Berkshelf configuration file with the ```-c``` option:

    busboy install -c /path/to/berkshelf/config.json
