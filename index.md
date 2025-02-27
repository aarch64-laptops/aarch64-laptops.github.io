---
layout: home
title: Device Status
---

This table contains highlights of the features supported for each Device.

Click on the Device link to see the full list.

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

To contribute to this page, see the contributors guide on the [aarch64-laptops Github](https://github.com/aarch64-laptops/aarch64-laptops.github.io/blob/main/README.md).
