+++
title = "Small list of spacemacs tips"
url = "post/small-list-of-spacemacs-tips/"
date = "2015-11-28T13:33:45-05:00"
tags = ["spacemacs", "tips"]
+++

**Note**: I've decided to abandoned the switch, and am working on making my vim
config better, giving me at least some of the neat features present in spacemacs.

---

I've recently started making the switch from vim + tmux to spacemacs.
Things have been very slow going, but occasionally I learn something that really
helps out.
I'll be posting those small learnings here.

FYI, `SPC` is pressing the "Space" key.
The keys after `SPC` are to be pressed in order with the specified
capitalization.

### edit the spacemacs config file

Incredibly useful at all times: `SPC f e d`

### highlight column 80

I typically want to show where column 80 is located, so I can choose to wrap my
code.
There's a way to toggle this, with `SPC t f` (toggle fill-column), but I want it
enabled by default.
To do this, you have to edit your config file (how-to is described above), and
add the following in the `defun dotspacemacs/user-config ()` section.

```
(turn-on-fci-mode)
```

`fci` is "fill-column-indicator", which by default is column 80.
