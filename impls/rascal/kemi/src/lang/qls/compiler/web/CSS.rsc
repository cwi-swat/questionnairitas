@license{
  Copyright (c) 2013 
  All rights reserved. This program and the accompanying materials
  are made available under the terms of the Eclipse Public License v1.0
  which accompanies this distribution, and is available at
  http://www.eclipse.org/legal/epl-v10.html
}
@contributor{Kevin van der Vlist - kevin@kevinvandervlist.nl}
@contributor{Jimi van der Woning - Jimi.vanderWoning@student.uva.nl}

module lang::qls::compiler::web::CSS

import Configuration;
import IO;
import lang::ql::analysis::State;
import lang::ql::\ast::AST;
import lang::ql::util::FormHelper;
import lang::qls::\ast::AST;
import lang::qls::util::StyleHelper;

void css(Stylesheet sheet, loc dest) {
  dest += getCSSStylesheetName();
  appendToFile(dest, css(sheet));
}

str css(Stylesheet s) {
  Form f = getAccompanyingForm(s);
  TypeMap typeMap = getTypeMap(f);

  return
    "<for(q <- typeMap) {>/* Question <q.ident> */
    '<for(r <- getStyleRules(q.ident, f, s)) {><css(q.ident, r)>
    '<}>
    '<}>
    ";
}

str blockIdent(str ident) = "<ident><getBlockSuffix()>";

str css(str ident, StyleRule r: intStyleRule(StyleAttr attr, int \value)) =
  "#<ident> { width: <\value>px; }"
    when attr is width;

str css(str ident, StyleRule r: intStyleRule(StyleAttr attr, int \value)) =
  "#<blockIdent(ident)> *:not(:first-child) { font-size: <\value>px; }"
    when attr is fontsize;

str css(str ident, StyleRule r: intStyleRule(StyleAttr attr, int \value)) =
  "#<blockIdent(ident)> label:first-child { font-size: <\value>px; }"
    when attr is labelFontsize;

// Other intStyleRules are not implemented in CSS
default str css(str ident, StyleRule r: intStyleRule(StyleAttr attr, int \value)) =
  "";

str css(str ident, StyleRule r: stringStyleRule(StyleAttr attr, str \value)) =
  "#<blockIdent(ident)> *:not(:first-child) { font-family: <\value>; }"
    when attr is font;

str css(str ident, StyleRule r: stringStyleRule(StyleAttr attr, str \value)) =
  "#<blockIdent(ident)> label:first-child { font-family: <\value>; }"
    when attr is labelFont;

// Other stringStyleRules are not implemented in CSS
str css(str ident, StyleRule r: stringStyleRule(StyleAttr attr, str \value)) =
  "";

str css(str ident, StyleRule r: colorStyleRule(StyleAttr attr, str \value)) =
  "#<blockIdent(ident)> *:not(:first-child) { color: <\value>; }"
    when attr is color;

str css(str ident, StyleRule r: colorStyleRule(StyleAttr attr, str \value)) =
  "#<blockIdent(ident)> label:first-child { color: <\value>; }"
    when attr is labelColor;

// Other colorStyleRules are not implemented in CSS
str css(str ident, StyleRule r: colorStyleRule(StyleAttr attr, str \value)) = "";

// Other types of StyleRules are unimplemented in CSS
str css(str ident, StyleRule r) = "";
