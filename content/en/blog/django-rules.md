---
title: "The Right Way to Manage Permissions in Django"
date: "2018-11-18T16:08:00"
topics:
  - "python"
  - "django"
slug: "django-rules"
feed: true
draft: true
---
<small>This post isn't about the built-in Django permission system (`auth.Permission` model) which is limited and should be used to manage admin access only.</small>

One typical question that I ask on an interview is related to managing permission in Django projects. I don't ask a direct question, though. Instead, I give the candidate a small project which involves permission management. The project is usually something like

> Build a collaborative blog engine. Any authenticated user can post to the blog. Post authors can edit their posts and superuser can edit any post.

Here's how a typical solution looks like:

```python
class AddPostView(...):

    def dispatch(self, request, *args, **kwargs):
        if not request.is_authenticated():
            return django.http.HttpResponseForbidden()
        return super(...)

class EditPostView(...):

    def dispatch(self, request, *args, **kwargs):
        ...
        if not (
            request.user.is_authenticated() or
            request.user.is_superuser or
            request.user == self.object.author
        ):
            return django.http.HttpResponseForbidden()
        return super(...)
```

Sometimes they use `LoginRequiredMixin` or `login_required` decorator, but it doesn't make much difference.

Next, we need to decide whether to show the *Edit* button in our template, and they do it like so:

```djangotemplate
{% if request.user.is_authenticated or request.user.is_superuser or request.user == post.author %}
  <a href="...">Edit</a>
{% endif %}
```

Let's say we want to add a new feature: on the first day of every month any user (even anonymous) is allowed to edit
and post on the blog.

```python
if not (
    datetime.date.today().day == 1 or
    request.user.is_authenticated() or
    request.user.is_superuser or
    request.user == self.object.author
):
    ...
```

So, we update the condition in the view, deploy it and get a bug report because we forgot to update the template.

This example shows a major drawback of this approach, code duplication. We have to maintain one set of rules in two
places in the code. Moreover, if the rules are complex they may be impossible to implement in the templates in the first
place.

The solution to the problem is to extract the permission checking logic into a separate component of the appllication
that other components will use.

There's a library crafted specifically for tht. Meet [rules](https://github.com/dfunckt/django-rules).

Here's how our example would look like if we used that library. First, we need to define a set of rules (predicates):

```python
# apps/blog/rules.py
from __future__ import absolute_import
import rules
import datetime

@rules.predicate
def is_first_day_in_month():
    return datetime.date.today().day == 1

@rules.predicate
def is_author(user, obj):
    return obj.author == user

rules.add_perm("blog.add_post", rules.is_authenticated)
rules.add_perm("blog.edit_post", is_first_day_in_month | rules.is_superuser | is_author)
```

Next, update the views:

```python
# apps/blog/views.py
from rules.contrib.views import PermissionRequiredMixin


class AddPostView(PermissionRequiredMixin, ...):

    permission_required = "blog.add_post"


class AddPostView(PermissionRequiredMixin, ...):

    permission_required = "blog.edit_post"

```

and the template:

```djangotemplate
{% load rules %}
{% has_perm "blog.edit_post" request.user post as can_edit %}
{% if can_edit %}
  <a href="...">Edit</a>
{% endif %}
```

To make all that work you need to add `rules` to `INSTALLED_APPS` and
`rules.permissions.ObjectPermissionBackend` to `AUTHENTICATION_BACKENDS` in your Django settings.

Using named permission such as `blog.edit_post` is not necessary. You can call the predicate functions directly:

```python
can_edit_post = is_first_day_in_month | rules.is_superuser | is_author

if can_edit_post(user, post):
    ...

```
