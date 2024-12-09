---
layout: default
---
<h1>{{ page.name }}</h1>
<div class="laptop">

<a href="{{site.url}}{{site.baseurl}}/">Return to Home Page</a>

<div class="laptop-status">
<h2>Device status</h2>
<table>
{% include layout_laptop.liquid %}
</table>
</div>

<div class="content">
{{ content }}
</div>

</div>
