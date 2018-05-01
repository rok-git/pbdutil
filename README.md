Sorry, this README is converted from man page using "groff -man -Thtml"

<!-- Creator     : groff version 1.19.2 -->
<!-- CreationDate: Tue May  1 23:50:01 2018 -->
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta name="generator" content="groff -Thtml, see www.gnu.org">
<meta http-equiv="Content-Type" content="text/html; charset=US-ASCII">
<meta name="Content-Style" content="text/css">
<style type="text/css">
       p     { margin-top: 0; margin-bottom: 0; }
       pre   { margin-top: 0; margin-bottom: 0; }
       table { margin-top: 0; margin-bottom: 0; }
</style>
<title></title>
</head>
<body>

<hr>


<p valign="top">PBDUTIL(1) BSD General Commands Manual
PBDUTIL(1)</p>

<p style="margin-top: 1em" valign="top"><b>NAME</b></p>

<p style="margin-left:8%;"><b>pbdutil</b> &mdash; read and
write the Pasteboard</p>


<p style="margin-top: 1em" valign="top"><b>SYNOPSIS</b></p>

<p style="margin-left:20%;"><b>pbdutil</b>
[<b>&minus;n&nbsp;</b><i>name</i>] <b>&minus;r</b>
<i>type</i> <b><br>
pbdutil</b> [<b>&minus;n&nbsp;</b><i>name</i>]
<b>&minus;R</b> <i>index</i> <b><br>
pbdutil</b> [<b>&minus;n&nbsp;</b><i>name</i>]
<b>&minus;w</b> <i>type</i> <b><br>
pbdutil</b> [<b>&minus;n&nbsp;</b><i>name</i>]
<b>&minus;l</b> [<b>&minus;v</b> [<b>&minus;v</b>
[<b>&minus;v</b>]]] <b><br>
pbdutil</b> [<b>&minus;n&nbsp;</b><i>name</i>] <b>&minus;C
<br>
pbdutil</b> [<b>&minus;n&nbsp;</b><i>name</i>]
<b>&minus;c</b></p>


<p style="margin-top: 1em" valign="top"><b>DESCRIPTION</b></p>

<p style="margin-left:8%;">The <b>pbdutil</b> read and
write content of the Pasteboard. When reading from the
Pasteboard, content of specified type is written on stdout.
When writing Pasteboard, data should be given via stdin. It
also displays information about what the Pasteboard
contains.</p>

<p style="margin-left:8%; margin-top: 1em">Following
options are available:</p>

<p style="margin-top: 1em" valign="top"><b>&minus;n</b>
<i>name</i></p>

<p style="margin-left:20%;">Use a private pasteboard named
as <i>name</i> instead of general (standard) pasteboard. If
there is no pasteboard with given name, one will be
created.</p>

<p style="margin-top: 1em" valign="top"><b>&minus;r</b>
<i>type</i></p>

<p style="margin-left:20%;">Read data from the Pasteboard
and write them to stdout. Available <i>types</i> are text,
rtf, rtfd, tiff, pict, pdf.</p>

<p style="margin-top: 1em" valign="top"><b>&minus;R</b>
<i>index</i></p>

<p style="margin-left:20%;">Read n-th data from the
Pasteboard and write them to stdout. <b>indiex</b> is the
number shown by &quot;pbdutil -lvvv&quot;</p>

<p style="margin-top: 1em" valign="top"><b>&minus;w</b>
<i>type</i></p>

<p style="margin-left:20%;">Read data from stdin and write
them out to Pasteboard. <i>Type</i> and the data must
match.</p>

<p style="margin-top: 1em" valign="top"><b>&minus;l</b>
[<b>&minus;v</b> [<b>&minus;v</b> [<b>&minus;v</b>]]]</p>

<p style="margin-left:20%;">List contents of Pasteboard
briefly. More <b>&minus;v</b> make the result more specific.
&quot;-lvvv&quot; also shows index number that can be used
with &quot;-C index&quot; option.</p>


<p style="margin-top: 1em" valign="top"><b>&minus;C</b></p>

<p style="margin-left:20%; margin-top: 1em">Count contents
of the Pasteboard</p>


<p style="margin-top: 1em" valign="top"><b>&minus;c</b></p>

<p style="margin-left:20%; margin-top: 1em">Clear content
of pasteboard.</p>


<p style="margin-left:8%; margin-top: 1em"><b>&quot;mkfw&quot;</b>
is a companion program that makes rtfd structured directory
from the output of pbdutil. If the Pasteboard contains data
of RTFD type, you can use mkfw.</p>


<p style="margin-top: 1em" valign="top"><b>EXAMPLES</b></p>

<p style="margin-left:8%;">To read and write data in
Pasteboard:</p>

<p style="margin-left:17%; margin-top: 1em">pbdutil -r tiff
&gt; /tmp/a.tiff <br>
pabutil -w text &lt; /etc/hosts</p>

<p style="margin-left:8%; margin-top: 1em">To clear data in
the Pasteboard:</p>

<p style="margin-left:17%; margin-top: 1em">pbdutil -c</p>

<p style="margin-left:8%; margin-top: 1em">To make rtfd
structured directory that can be opend with
TextEdit.app:</p>

<p style="margin-left:17%; margin-top: 1em">pbdutil -r rtfd
| mkfw FILE.rtfd</p>

<p style="margin-top: 1em" valign="top"><b>BUGS</b></p>

<p style="margin-left:8%;">There is no way to know private
pastebords&rsquo; names. More than one type of data cannot
be stored into Pasteboard. For example, when you copy a page
from Safari, then Pasteboard contains both text and rtf
data. But you cannot store both text and rtf data using
pbdutil. You can store only one type of data using
pbdutil.</p>

<p style="margin-left:8%; margin-top: 1em">Private
pasteboard created by issuing &rsquo;pbdutil -n name&rsquo;
cannot be removed. &acute;pbdutil -n name -c&rsquo; only
clears the contents of the pasteboard.</p>

<p style="margin-top: 1em" valign="top"><b>SEE ALSO</b></p>

<p style="margin-left:8%;">pbpaste(1), pbcopy(1)</p>

<p style="margin-top: 1em" valign="top"><b>AUTHOR</b></p>

<p style="margin-left:8%;">CHOI Kyong-Rok.</p>

<p style="margin-left:8%; margin-top: 1em">Mac OS X
May&nbsp;1, 2018 Mac OS X</p>
<hr>
</body>
</html>
