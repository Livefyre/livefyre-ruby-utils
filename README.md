# Livefyre Ruby Utility Classes
[![Gem Version](https://badge.fury.io/rb/livefyre.png)](http://badge.fury.io/rb/livefyre)

Livefyre's official library for common server-side tasks necessary for getting Livefyre apps (comments, reviews, etc.) working on your website.

## Installation

Add this line to your application's Gemfile:

    gem 'livefyre'

Or install it yourself:

    $ gem install livefyre

## Usage

Creating tokens:

**Livefyre token:**

```ruby
Livefyre.get_network('network_name', 'network_key').build_lf_token
```

**User auth token:**

```ruby
network = Livefyre.get_network('network_name', 'network_key')

network.build_user_auth_token('user_id', 'display_name', expires)
```

**Collection meta token:**
The 'stream' argument is optional.

```ruby
network = Livefyre.get_network('network_name', 'network_key')
site = network.get_site('site_id', 'site_key')

site.build_collection_meta_token('title', 'article_id', 'url', 'tags', 'stream')
```

To validate a Livefyre token:

```ruby
network = Livefyre.get_network('network_name', 'network_key')
network.validate_livefyre_token('token')
```

To send Livefyre a user sync url and then have Livefyre pull user data from that url:

```ruby
network = Livefyre.get_network('network_name', 'network_key')

network.set_user_sync_url('url{id}')
network.sync_user('system')
```

To retrieve content collection data:

```ruby
network = Livefyre.get_network('network_name', 'network_key')

site = network.get_site('site_id', 'site_key')
site.get_collection_content('article_id')
```

## Documentation

Located [here](http://answers.livefyre.com/developers/libraries).

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

Note: any feature update on any of Livefyre's libraries will need to be reflected on all language libraries. We will try and accommodate when we find a request useful, but please be aware of the time it may take.

License
=======

MIT