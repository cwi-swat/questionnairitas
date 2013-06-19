@license{
  Copyright (c) 2013 
  All rights reserved. This program and the accompanying materials
  are made available under the terms of the Eclipse Public License v1.0
  which accompanies this distribution, and is available at
  http://www.eclipse.org/legal/epl-v10.html
}
@contributor{Kevin van der Vlist - kevin@kevinvandervlist.nl}
@contributor{Jimi van der Woning - Jimi.vanderWoning@student.uva.nl}

module lang::ql::compiler::PrettyPrinter

import Node;
import lang::ql::\ast::AST;
import lang::ql::\ast::Keyword;
import lang::ql::util::ParenthesizeExpressions;

str printExpression(Expr p, str print) = "(<print>)"
  when "parentheses" in getAnnotations(p);

default str printExpression(Expr p, str print) = print;

public str prettyPrint(Form form) =
  "form <ppID(form.formName.ident)> { <for(e <- form.formElements) {>
  '  <prettyPrint(e)><}>
  '}
  '";

public str prettyPrint(Statement item: question(Question question)) = 
  prettyPrint(question);

public str prettyPrint(Question q: 
    question(questionText, answerDataType, answerIdentifier)) =
  "<questionText.text>
  '  <answerDataType.name> <ppID(answerIdentifier.ident)>";

public str prettyPrint(Question q: 
    question(questionText, answerDataType, answerIdentifier, cf)) =
  "<questionText.text>
  '  <answerDataType.name> <ppID(answerIdentifier.ident)> = <prettyPrint(cf)>";

public str prettyPrint(Statement item: 
    ifCondition(Conditional ifPart, list[Conditional] elseIfs, 
    list[ElsePart] elsePart)) = 
    "if(<prettyPrint(ifPart.condition)>) { <for(e <- ifPart.body) {>
    '  <prettyPrint(e)><}><for(ei <- elseIfs) { >
    '} else if(<prettyPrint(ei.condition)>) { <for(e <- ei.body) {>
    '  <prettyPrint(e)><}><}><for(ep <- elsePart) { >
    '} else { <for(e <- ep.body) {>
    '  <prettyPrint(e)><}><}>
    '}";
    
public str prettyPrint(Expr e) =
  prettyPrintParen(parenizeExpr(e));

str prettyPrintParen(p:pos(Expr posValue)) = 
  printExpression(p, "+<prettyPrintParen(posValue)>");

str prettyPrintParen(p:neg(Expr negValue)) =
  printExpression(p, "-<prettyPrintParen(negValue)>");

str prettyPrintParen(p:not(Expr notValue)) =
  printExpression(p, "!<prettyPrintParen(notValue)>");

str prettyPrintParen(p:mul(multiplicand, multiplier)) =
  printExpression(p, 
    "<prettyPrintParen(multiplicand)> * <prettyPrintParen(multiplier)>");

str prettyPrintParen(p:div(numerator, denominator)) =
  printExpression(p, 
    "<prettyPrintParen(numerator)> / <prettyPrintParen(denominator)>");

str prettyPrintParen(p:add(leftAddend, rightAddend)) =
  printExpression(p, 
    "<prettyPrintParen(leftAddend)> + <prettyPrintParen(rightAddend)>");

str prettyPrintParen(p:sub(minuend, subtrahend)) =
  printExpression(p, "<prettyPrintParen(minuend)> - <prettyPrintParen(subtrahend)>");

str prettyPrintParen(p:lt(left, right)) =
  printExpression(p, "<prettyPrintParen(left)> \< <prettyPrintParen(right)>");

str prettyPrintParen(p:leq(left, right)) =
  printExpression(p, "<prettyPrintParen(left)> \<= <prettyPrintParen(right)>");

str prettyPrintParen(p:gt(left, right)) =
  printExpression(p, "<prettyPrintParen(left)> \> <prettyPrintParen(right)>");

str prettyPrintParen(p:geq(left, right)) =
  printExpression(p, 
    "<prettyPrintParen(left)> \>= <prettyPrintParen(right)>");

str prettyPrintParen(p:equ(left, right)) =
  printExpression(p, "<prettyPrintParen(left)> == <prettyPrintParen(right)>");

str prettyPrintParen(p:neq(left, right)) =
  printExpression(p, "<prettyPrintParen(left)> != <prettyPrintParen(right)>");

str prettyPrintParen(p:and(left, right)) =
  printExpression(p, "<prettyPrintParen(left)> && <prettyPrintParen(right)>");

str prettyPrintParen(p:or(left, right)) =
  printExpression(p, "<prettyPrintParen(left)> || <prettyPrintParen(right)>");

str prettyPrintParen(ident(str name)) = "<ppID(name)>";

str prettyPrintParen(\int(int intValue)) = "<intValue>";

str prettyPrintParen(money(real moneyValue)) = "<moneyValue>";

str prettyPrintParen(boolean(bool booleanValue)) = "<booleanValue>";

str prettyPrintParen(date(str dateValue)) = "<dateValue>";

str prettyPrintParen(string(str text)) = "<text>";

default str ppID(str ident) = ident;

str ppID(str ident) = "\\<ident>" when ident in keywords;
