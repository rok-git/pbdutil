Sorry, this README is converted from man page using "mandoc -T html"

<!DOCTYPE html>
<html>
<!-- This is an automatically generated file.  Do not edit.
   $Id: pbdutil.1,v 1.7 2018/05/01 08:39:02 rok Exp $
   -->
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <style>
    table.head, table.foot { width: 100%; }
    td.head-rtitle, td.foot-os { text-align: right; }
    td.head-vol { text-align: center; }
    .Nd, .Bf, .Op { display: inline; }
    .Pa, .Ad { font-style: italic; }
    .Ms { font-weight: bold; }
    .Bl-diag > dt { font-weight: bold; }
    code.Nm, .Fl, .Cm, .Ic, code.In, .Fd, .Fn, .Cd { font-weight: bold;
      font-family: inherit; }
  </style>
  <title>PBDUTIL(1)</title>
</head>
<body>
<table class="head">
  <tr>
    <td class="head-ltitle">PBDUTIL(1)</td>
    <td class="head-vol">General Commands Manual</td>
    <td class="head-rtitle">PBDUTIL(1)</td>
  </tr>
</table>
<div class="manual-text">
<section class="Sh">
<h1 class="Sh" id="NAME"><a class="permalink" href="#NAME">NAME</a></h1>
<p class="Pp"><code class="Nm">pbdutil</code> &#x2014; <span class="Nd">read and
    write the Pasteboard</span></p>
</section>
<section class="Sh">
<h1 class="Sh" id="SYNOPSIS"><a class="permalink" href="#SYNOPSIS">SYNOPSIS</a></h1>
<table class="Nm">
  <tr>
    <td><code class="Nm">pbdutil</code></td>
    <td>[<code class="Fl">-n</code> <var class="Ar">name</var>]
      <code class="Fl">-r</code> <var class="Ar">type</var></td>
  </tr>
</table>
<br/>
<table class="Nm">
  <tr>
    <td><code class="Nm">pbdutil</code></td>
    <td>[<code class="Fl">-n</code> <var class="Ar">name</var>]
      <code class="Fl">-R</code> <var class="Ar">index</var></td>
  </tr>
</table>
<br/>
<table class="Nm">
  <tr>
    <td><code class="Nm">pbdutil</code></td>
    <td>[<code class="Fl">-n</code> <var class="Ar">name</var>]
      <code class="Fl">-w</code> <var class="Ar">type</var></td>
  </tr>
</table>
<br/>
<table class="Nm">
  <tr>
    <td><code class="Nm">pbdutil</code></td>
    <td>[<code class="Fl">-n</code> <var class="Ar">name</var>]
      <code class="Fl">-l</code> [<code class="Fl">-v</code>
      [<code class="Fl">-v</code> [<code class="Fl">-v</code>]]]</td>
  </tr>
</table>
<br/>
<table class="Nm">
  <tr>
    <td><code class="Nm">pbdutil</code></td>
    <td>[<code class="Fl">-n</code> <var class="Ar">name</var>]
      <code class="Fl">-C</code></td>
  </tr>
</table>
<br/>
<table class="Nm">
  <tr>
    <td><code class="Nm">pbdutil</code></td>
    <td>[<code class="Fl">-n</code> <var class="Ar">name</var>]
      <code class="Fl">-c</code></td>
  </tr>
</table>
<br/>
<table class="Nm">
  <tr>
    <td><code class="Nm">pbdutil</code></td>
    <td><code class="Fl">-n</code> <var class="Ar">name</var>
      <code class="Fl">-d</code></td>
  </tr>
</table>
</section>
<section class="Sh">
<h1 class="Sh" id="DESCRIPTION"><a class="permalink" href="#DESCRIPTION">DESCRIPTION</a></h1>
<p class="Pp">The <code class="Nm">pbdutil</code> read and write content of the
    pasteboard. When reading from the pasteboard, content of specified type is
    written on stdout. When writing Pasteboard, data should be given via stdin.
    It also displays information about what the pasteboard contains.</p>
<p class="Pp">Following options are available:</p>
<dl class="Bl-tag">
  <dt id="n"><a class="permalink" href="#n"><code class="Fl">-n</code></a>
    <var class="Ar">name</var></dt>
  <dd>Use the private pasteboard named as <var class="Ar">name</var> instead of
      the general (standard) pasteboard. If there is no pasteboards with given
      name, one will be created.</dd>
  <dt id="r"><a class="permalink" href="#r"><code class="Fl">-r</code></a>
    <var class="Ar">type</var></dt>
  <dd>Read data from the pasteboard and write them to stdout. Available
      <var class="Ar">types</var> are text, rtf, rtfd, tiff, png, pdf, html,
      etc. (Macintosh PICT is no longer supported).</dd>
  <dt id="R"><a class="permalink" href="#R"><code class="Fl">-R</code></a>
    <var class="Ar">index</var></dt>
  <dd>Read n-th data from the pasteboard and write the data to stdout. .Ar index
      is the number shown by &quot;pbdutil -lvvv&quot;</dd>
  <dt id="w"><a class="permalink" href="#w"><code class="Fl">-w</code></a>
    <var class="Ar">type</var></dt>
  <dd>Read data from stdin and write them out to Pasteboard.
      <var class="Ar">type</var> and the data must match.</dd>
  <dt id="l"><a class="permalink" href="#l"><code class="Fl">-l</code></a>
    [<code class="Fl">-v</code> [<code class="Fl">-v</code>
    [<code class="Fl">-v</code>]]]</dt>
  <dd>List contents of Pasteboard briefly. More <code class="Fl">-v</code> make
      the result more specific. &quot;-lvvv&quot; also shows index number that
      can be used with &quot;-R index&quot; option.</dd>
  <dt id="C"><a class="permalink" href="#C"><code class="Fl">-C</code></a></dt>
  <dd>Count contents of the pasteboard</dd>
  <dt id="c"><a class="permalink" href="#c"><code class="Fl">-c</code></a></dt>
  <dd>Clear contents of the pasteboard.</dd>
  <dt id="n~2"><a class="permalink" href="#n~2"><code class="Fl">-n</code></a>
    <var class="Ar">name</var> <code class="Fl">-d</code></dt>
  <dd>Release the resources of the named pasteboard. The name of the pasteboard
      must be specified as &quot;-n name&quot; and you cannot release the
      General (default) pasteboard.</dd>
</dl>
<p class="Pp" id="mkfw"><a class="permalink" href="#mkfw"><b class="Sy">mkfw is
    a companion program that makes rtfd structured directory from the output of
    pbdutil. If the pasteboard contains data of RTFD type, you can use
    mkfw.</b></a></p>
</section>
<section class="Sh">
<h1 class="Sh" id="EXAMPLES"><a class="permalink" href="#EXAMPLES">EXAMPLES</a></h1>
<p class="Pp">To read and write data in Pasteboard:</p>
<p class="Pp"></p>
<div class="Bd Bd-indent"><code class="Li">pbdutil -r tiff &gt;
  /tmp/a.tiff</code></div>
<div class="Bd Bd-indent"><code class="Li">pbdutil -w text &lt;
  /etc/hosts</code></div>
<p class="Pp">To clear data in the pasteboard:</p>
<p class="Pp"></p>
<div class="Bd Bd-indent"><code class="Li">pbdutil -c</code></div>
<p class="Pp">To make rtfd structured directory that can be opened with
    TextEdit.app:</p>
<p class="Pp"></p>
<div class="Bd Bd-indent"><code class="Li">pbdutil -r rtfd | mkfw
  FILE.rtfd</code></div>
</section>
<section class="Sh">
<h1 class="Sh" id="BUGS"><a class="permalink" href="#BUGS">BUGS</a></h1>
<p class="Pp">There is no way to know private pasteboards' names.</p>
<p class="Pp">More than one type of data cannot be stored into Pasteboard. For
    example, when you copy a page from Safari, then Pasteboard contains both
    text and rtf data. But you cannot store both text and rtf data using
    pbdutil. You can store only one type of data using pbdutil.</p>
<p class="Pp">Now, private pasteboards created by issuing &quot;pbdutil -n
    name&quot; can be removed by using &quot;-d&quot; option with &quot;-n
    name&quot;. However, you have to remember the names of pasteboards that you
    created with &quot;-n name&quot; because there is still no way to know the
    names of existing private pasteboards.</p>
</section>
<section class="Sh">
<h1 class="Sh" id="SEE_ALSO"><a class="permalink" href="#SEE_ALSO">SEE
  ALSO</a></h1>
<p class="Pp"><a class="Xr">pbpaste(1)</a>, <a class="Xr">pbcopy(1)</a></p>
</section>
<section class="Sh">
<h1 class="Sh" id="AUTHOR"><a class="permalink" href="#AUTHOR">AUTHOR</a></h1>
<p class="Pp">CHOI Kyong-Rok.</p>
</section>
</div>
<table class="foot">
  <tr>
    <td class="foot-date">-</td>
    <td class="foot-os">Mac OS X</td>
  </tr>
</table>
</body>
</html>
