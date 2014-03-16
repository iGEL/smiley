[![Code Climate](https://codeclimate.com/github/iGEL/smiley.png)](https://codeclimate.com/github/iGEL/smiley)
[![Build Status](https://travis-ci.org/iGEL/smiley.png?branch=master)](https://travis-ci.org/iGEL/smiley)
(Tested: Ruby 2.1.1, 2.0.0, 1.9.3, 1.9.2, 1.8.7, Rubinius, Jruby)

Smiley
======

This is a small library to pass text emoticons like into cute smiley images your users will like. To be more accurate,
this lib will parse them into `<em class="smiley smiley-grin></em>`, which you can style with css to show the smiley
image. This way, you can use [CSS sprites](http://css-tricks.com/css-sprites/) to make them load faster.

Usage
=====

First, configure the smileys you want to have converted in a yml file. If you use this lib with Ruby on Rails, the
default position for this file is in `config/smileys.yml`.

```yml
cool:
  tokens: ':cool: 8-) 8)'
cry:
  tokens: ":&#x27;( ;( :&#x27;-(" # HTML escaped, since we work in the escaped form
grin:
  tokens: ':-D :D'
```

You can configure multiple forms for the same smiley. In this example, `:cool:`, `8-)` and `8)` will all produce
the same smiley.

Next, pass your string through `smiley`. If you're inside of Rails, `smiley` will escape html unsafe Strings and
mark the result as html safe. Remember to do it yourself if you use the lib outside of Rails.

Helper:
```ruby
def smileys(str)
  Smiley.new.parse(str)
end
```
Haml:
```haml
.post
  = smileys("Wow, they're alive :cool: :D")
```

The last step is to setup the CSS, so the images will be displayed.

SCSS:
```scss
.smiley { // All smileys have this class
  display: inline-block;
  width: 15px;
  height: 15px;
  background: image-url('smileys/sprite.png');
}
.smiley-cool {
  background: image-url('smileys/cool.gif'); // animated
}
.smiley-cry {
  background-position: 0 0;
}
.smiley-grin {
  width: 20px;
  background-position: 0 -15px;
}
```

Configuration
=============

So far, `smiley` has these configuration options:

```ruby
# The prefix for the CSS class, e.g. smiley in smiley-grin, defaults to smiley
Smiley.each_class_prefix = 'icons'

# The CSS class that is added to all smileys, defaults to smiley
Smiley.all_class = 'emoji'

# defaults to :dashed, meaning class names like smiley-big-grin
# :camel-case will generate class names like smileyBigGrin, :snake_case like smiley_big_grin
Smiley.css_class_style = :camel_case

# YAML file with the smiley definition. Default in Rails is config/smileys.yml
# No default if not used with Rails
Smiley.smiley_file = 'data/smileys.yml'
```

License
=======

MIT (see `MIT-LICENSE`)
