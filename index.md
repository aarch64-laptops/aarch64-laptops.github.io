---
layout: home
---
<div>
<h2>Device status</h2>
<p>This table contains highlights of the features supported for each Device.</p>
<p>Click on the Device link to see the full list.</p>
<table>
<thead>
{% include index_laptop_header.liquid %}
</thead>
<tbody>
{% for d in site.laptop %}
<tr>
<td><a href="{{d.url | absolute_url}}">{{d.name}}</a></td>
{% include index_laptop_status.liquid %}
<td><a href="{{d.url | absolute_url}}">{{d.name}}</a></td>
</tr>
{% endfor %}
</tbody>
<tfoot>
{% include index_laptop_header.liquid %}
</tfoot>
</table>
</div>

<p> Contribute to this page, see the contributors guide on <a
href="https://github.com/aarch64-laptops/aarch64-laptops.github.io/blob/main/README.md">
aarch64-laptops Github</a>.</p>
