---
# Feel free to add content and custom Front Matter to this file.
# To modify the layout, see https://jekyllrb.com/docs/themes/#overriding-theme-defaults

layout: home
---
<div>
<h2>Laptop status</h2>
<p>This table contains full set of the features supported for each laptop.</p>
<table>
<thead>
{% include full_laptop_header.liquid %}
</thead>
<tbody>
{% for d in site.laptop %}
<tr>
<td><a href="{{d.url | absolute_url}}">{{d.name}}</a></td>
{% include full_laptop_status.liquid %}
<td><a href="{{d.url | absolute_url}}">{{d.name}}</a></td>
</tr>
{% endfor %}
</tbody>
<tfoot>
{% include full_laptop_header.liquid %}
</tfoot>
</table>
</div>
