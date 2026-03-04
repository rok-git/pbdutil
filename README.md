Sorry, this README is converted from man page using "mandoc -T markdown"

PBDUTIL(1) - General Commands Manual

# NAME

**pbdutil** - read and write the Pasteboard

# SYNOPSIS

**pbdutil**
\[**-n**&nbsp;*name*]
**-r**&nbsp;*type*  
**pbdutil**
\[**-n**&nbsp;*name*]
**-R**&nbsp;*index*  
**pbdutil**
\[**-n**&nbsp;*name*]
**-w**&nbsp;*type*  
**pbdutil**
\[**-n**&nbsp;*name*]
**-l**&nbsp;\[**-v**&nbsp;\[**-v**&nbsp;\[**-v**]]]  
**pbdutil**
\[**-n**&nbsp;*name*]
**-C**  
**pbdutil**
\[**-n**&nbsp;*name*]
**-c**  
**pbdutil**
**-n**&nbsp;*name*
**-d**

# DESCRIPTION

The
**pbdutil**
read and write content of the pasteboard.  When reading from the pasteboard,
content of specified type is written on stdout.  When writing
Pasteboard, data should be given via stdin.  It also displays information
about what the pasteboard contains.

Following options are available:

**-n** *name*

> Use the private pasteboard named as
> *name*
> instead of the general (standard) pasteboard.  If there is no pasteboards with
> given name, one will be created.

**-r** *type*

> Read data from the pasteboard and write them to stdout.  Available
> *types*
> are text, rtf, rtfd, tiff, png, pdf, html, etc. (Macintosh PICT is no longer supported).

**-R** *index*

> Read n-th data from the pasteboard and write the data to stdout.  .Ar index is the
> number shown by "pbdutil -lvvv"

**-w** *type*

> Read data from stdin and write them out to Pasteboard.
> *type*
> and the data must match.

**-l** \[**-v** \[**-v** \[**-v**]]]

> List contents of Pasteboard briefly.  More
> **-v**
> make the result more specific.  "-lvvv" also shows index number that can
> be used with "-R index" option.

**-C**

> Count contents of the pasteboard

**-c**

> Clear contents of the pasteboard.

**-n** *name* **-d**

> Release the resources of the named pasteboard.  The name of the pasteboard must be specified as "-n name" and you cannot release the General (default) pasteboard.

**mkfw is a companion program that makes rtfd structured directory from the output of pbdutil. If the pasteboard contains data of RTFD type, you can use mkfw.**

# EXAMPLES

To read and write data in Pasteboard:

	pbdutil -r tiff > /tmp/a.tiff

	pbdutil -w text < /etc/hosts

To clear data in the pasteboard:

	pbdutil -c

To make rtfd structured directory that can be opened with TextEdit.app:

	pbdutil -r rtfd | mkfw FILE.rtfd

# BUGS

There is no way to know private pasteboards' names.

More than one type of data cannot be stored into Pasteboard.  For example,
when you copy a page from Safari, then Pasteboard contains both text and rtf
data.  But you cannot store both text and rtf data using pbdutil.  You can
store only one type of data using pbdutil.

Now, private pasteboards created by issuing "pbdutil -n name" can be removed by using "-d" option with "-n name".  However, you have to remember the names of pasteboards that you created with "-n name" because there is still no way to know the names of existing private pasteboards.

# SEE ALSO

pbpaste(1),
pbcopy(1)

# AUTHOR

CHOI Kyong-Rok.

Mac OS X - -
