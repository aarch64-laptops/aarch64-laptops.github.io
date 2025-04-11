## Welcome to AArch64 laptops!

This website is written in Markdown and can be edited offline using git or
online using the github web interface.

The canonical location for the fully rendered website is:
[https://aarch64-laptops.github.io](https://aarch64-laptops.github.io).


## Contributing to this repo

If you are logged into github then you can edit the website by visiting
the non-rendered version of the homepage (the edit button is in the
top-right):
[https://github.com/aarch64-laptops/aarch64-laptops.github.io/blob/main/index.md](https://github.com/aarch64-laptops/aarch64-laptops.github.io/blob/main/index.md)

You can also use your normal git tooling to edit the website offline.
Try:

```
git clone https://github.com/aarch64-laptops/aarch64-laptops.github.io
cd aarch64-laptops.github.io
./regen.py
gem install bundler jekyll
bundle config set --local path 'vendor'
bundle install
bundle exec jekyll serve
```

If on an aarch64 host, you will need to manually edit
[Gemfile.lock](/Gemfile.lock) and adjust the arch suffix on nokogiri before running `bundle install`.

## Copyright and licensing

The AArch64 Laptops website is copyrighted by our contributors (see our
[git repo
history](https://github.com/aarch64-laptops/aarch64-laptops.github.io/commits/main)
for details) and is licensed under [CC BY-SA 4.0](LICENSE.md).
