---
title: Blog
layout: default
---

I use this blog to document solutions to problems that came up during my work or hobby projects.

<ul>
  {% for post in site.posts %}
    <li>
      <a href="{{ post.url }}">{{ post.title }}</a>
    </li>
  {% endfor %}
</ul>
