# Developer Notes

## General Styleguide

* All powershell commands are preferred to be on one line.
* 2 space indentation.
* Opening [{( are not newlined.
* Docstrings are *Required*. Please following existing formats. Hardwrap
  @80 characters.
* Vars in Docstrings: one line preferred. If multiline, newline, 4 space
  indent and wrap at 80 chars.

```Docstring
# One line descriptor of method
#
# Additional information pertaining to method and how it works.
#
# Args:
#   [variable]: [Datatype] short description of variable and what it's for.
#   [variable]:
#       [Datatype] more than 80 character description of variable and/or how
#       the data is structured or used.
#
# Returns:
#   [Datatype] short description of what is returned.
#
# Raises:
#   [Exception] short description of why it's raised.
#
```


## New Modules

* Url's for references can be on one line (violating 80 char limit)
* Description/LongDescription - hard wrap @80chars.
* URL DOC: one line per url
* Keep specific interfaces executing in specific methods. This will prevent
  issues in the future if specific interfaces can be disabled.
* Use Interfaces instead of directly accessing powershell functions. This
  is because these interfaces specifically log what is going on so the end
  user can log it and determine pre and post modification changes.
* Name your module appropriately, closest to the service or change that is
  happening.
* Overloaded methods that have the same parameters and return values as the
  original method do not need new docstrings.