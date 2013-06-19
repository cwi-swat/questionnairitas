@license{
  Copyright (c) 2013 
  All rights reserved. This program and the accompanying materials
  are made available under the terms of the Eclipse Public License v1.0
  which accompanies this distribution, and is available at
  http://www.eclipse.org/legal/epl-v10.html
}
@contributor{Kevin van der Vlist - kevin@kevinvandervlist.nl}
@contributor{Jimi van der Woning - Jimi.vanderWoning@student.uva.nl}

module lang::ql::analysis::Expression

import Node;
import Set;
import lang::ql::analysis::Messages;
import lang::ql::analysis::State;
import lang::ql::\ast::AST;
import util::IDE;

private Type i() = integerType("integer");
private Type m() = moneyType("money");
private Type b() = booleanType("boolean");
private Type d() = dateType("date");
private Type s() = stringType("string");
private Type err() = invalidType("invalid");
private Type undef() = undefinedType("undefined");

/*
 * This table contains all the expression types, 
 * and shows which type can be used in conjunction with 
 * that operator.
 * For example: A 'mul' operation is allowed on both integers and money.
 */ 
private map[str, set[Type]] typesByOperator = (
  "int": {i()}, 
  "money": {m()},
  "boolean": {b()},
  "date": {d()},
  "string": {s()},
  
  "pos": {i(), m()},
  "neg": {i(), m()},
  "not": {b()},
  
  "mul": {i(), m()},
  "div": {i(), m()},
  "add": {i(), m()},
  "sub": {i(), m()},
  
  "lt": {i(), m(), d(), s()},
  "leq": {i(), m(), d(), s()},
  "gt": {i(), m(), d(), s()},
  "geq": {i(), m(), d(), s()},
  "equ": {i(), m(), b(), d(), s()},
  "neq": {i(), m(), b(), d(), s()},
  
  "and": {b()},
  "or": {b()}
);

private alias Types = map[str, set[Type]];

public set[Message] analyzeExpression(SAS sas, Expr expression) {
  types = (
    key.ident : {sas.definitions[key]} | 
    key <- sas.definitions
  ) + typesByOperator;
  <_, messages> = inferExprType(types, expression);
  return messages;
}

/*
 * This function checks the type usage of an assignment expression.
 * Usage is correct if:
 * - Declared type is money, evaluated type of expression is integer
 * - Declared and evaluating type are the same. 
 */
public set[Message] analyzeAssignmentExpression(SAS sas, Type \type, 
    Expr expression) {
  types = (
    key.ident : {sas.definitions[key]} | 
    key <- sas.definitions
  ) + typesByOperator;
  <infType, messages> = inferExprType(types, expression);
  
  if(infType == i() && \type == m()) 
    return messages;

  if(infType == \type) 
    return messages;
    
  return 
    messages + {invalidAssignmentMessage(\type, infType, expression@location)};
}

// The following block contains all Expr patterns that are available.
private tuple[Type, set[Message]] inferExprType(Types types, 
    Expr e: pos(Expr posValue)) =
  analyzeUnaryExpr(types, e, posValue);

private tuple[Type, set[Message]] inferExprType(Types types, 
    Expr e: neg(Expr negValue)) =
  analyzeUnaryExpr(types, e, negValue);

private tuple[Type, set[Message]] inferExprType(Types types, 
    Expr e: not(Expr notValue)) =
  analyzeUnaryExpr(types, e, notValue);

private tuple[Type, set[Message]] inferExprType(Types types, 
    Expr e: lt(Expr left, Expr right)) =
  analyzeRelationalExpr(types, e, left, right);

private tuple[Type, set[Message]] inferExprType(Types types, 
    Expr e: leq(Expr left, Expr right)) =
  analyzeRelationalExpr(types, e, left, right);

private tuple[Type, set[Message]] inferExprType(Types types, 
    Expr e: gt(Expr left, Expr right)) =
  analyzeRelationalExpr(types, e, left, right);

private tuple[Type, set[Message]] inferExprType(Types types, 
    Expr e: geq(Expr left, Expr right)) =
  analyzeRelationalExpr(types, e, left, right);

private tuple[Type, set[Message]] inferExprType(Types types, 
    Expr e: equ(Expr left, Expr right)) =
  analyzeRelationalExpr(types, e, left, right);

private tuple[Type, set[Message]] inferExprType(Types types, 
    Expr e: neq(Expr left, Expr right)) =
  analyzeRelationalExpr(types, e, left, right);

private tuple[Type, set[Message]] inferExprType(Types types, 
    Expr e: and(Expr left, Expr right)) =
  analyzeAndOrExpr(types, e, left, right);

private tuple[Type, set[Message]] inferExprType(Types types, 
    Expr e: or(Expr left, Expr right)) =
  analyzeAndOrExpr(types, e, left, right);

private tuple[Type, set[Message]] inferExprType(Types types, 
    Expr e: mul(Expr multiplicand, Expr multiplier)) =
  analyzeBinaryExpr(types, e, multiplicand, multiplier);
  
private tuple[Type, set[Message]] inferExprType(Types types, 
    Expr e: div(Expr numerator, Expr denominator)) =
  analyzeBinaryExpr(types, e, numerator, denominator);

private tuple[Type, set[Message]] inferExprType(Types types, 
    Expr e: add(Expr leftAddend, Expr rightAddend)) =
  analyzeBinaryExpr(types, e, leftAddend, rightAddend);

private tuple[Type, set[Message]] inferExprType(Types types, 
    Expr e: sub(Expr minuend, Expr subtrahend)) =
  analyzeBinaryExpr(types, e, minuend, subtrahend);
  
private tuple[Type, set[Message]] inferExprType(Types types, 
    Expr e: ident(str name)) =
  <getOneFrom(types[name]), {}>
    when name in types;
  
private tuple[Type, set[Message]] inferExprType(Types types, 
    Expr e: ident(str name)) =
  <undef(), {undeclaredIdentifierMessage(name, e@location)}>;

private default tuple[Type, set[Message]] inferExprType(Types types, Expr e) =
  <getOneFrom(types[getName(e)]), {}>;

/* 
 * This function checks whether the usage of a unary expression is correct.
 * There are no special cases, other then the used value not being undeclared 
 * and being a member of the type table above.
 */
private tuple[Type, set[Message]] analyzeUnaryExpr(Types types, Expr parent, 
    Expr val) {
  <infType, messages> = inferExprType(types, val);
  
  if(infType == undef())
    return <err(), messages>;

  if(infType notin types[getName(parent)])
    return <err(), messages + {invalidTypeMessage(parent@location)}>;
  
  return <infType, messages>;
}

/*
 * This function checks whether the usage of a relational expression is correct.
 * Usage is correct if: 
 * - Neither of the members are undefined
 * - Members are of allowed type of operator in question
 * - Left and right hand side are of same type
 * - An exception of the above rule is mingling integers and money. 
 *   The resulting tye will be boolean.
 */
private tuple[Type, set[Message]] analyzeRelationalExpr(Types types,
    Expr parent, Expr lhs, Expr rhs) {
  <lhtype, lhmessages> = inferExprType(types, lhs);
  <rhtype, rhmessages> = inferExprType(types, rhs);
  
  if(lhtype == undef() || rhtype == undef())
    return <err(), rhmessages + lhmessages>;

  if(lhtype notin types[getName(parent)] || rhtype notin types[getName(parent)])
    return 
      <err(), lhmessages + rhmessages + {invalidTypeMessage(parent@location)}>;
  
  if(lhtype == rhtype)
    return <b(), lhmessages + rhmessages>;
    
  if(lhtype in {m(), i()} &&
    rhtype in {m(), i()}) 
    return <b(), lhmessages + rhmessages>;

  return <err(), lhmessages + rhmessages>;
}

/*
 * This function checks whether the usage of a and/or expression is correct.
 * Usage is correct if: 
 * - Neither of the members are undefined
 * - Members are of allowed type of operator in question
 * - Left and right hand side are booleans
 */
private tuple[Type, set[Message]] analyzeAndOrExpr(Types types, Expr parent, 
    Expr lhs, Expr rhs) {
  <lhtype, lhmessages> = inferExprType(types, lhs);
  <rhtype, rhmessages> = inferExprType(types, rhs);

  if(lhtype == undef() || rhtype == undef())
    return <err(), lhmessages + rhmessages>;

  if(lhtype notin types[getName(parent)] || rhtype notin types[getName(parent)])
    return 
      <err(), lhmessages + rhmessages + {invalidTypeMessage(parent@location)}>;
  
  if(lhtype == b() && rhtype == b())
    return <b(), lhmessages + rhmessages>;
  
  return <err(), lhmessages + rhmessages>;
}

/*
 * This function checks whether the usage of a relational expression is correct.
 * Usage is correct if: 
 * - Neither of the members are undefined
 * - Left and right are both strings: result will be a string as well
 * - Members are of allowed type of operator in question 
 * - Left and right hand side are integers: result will be an integer
 * - Left and right hand side contain one or two moneys: result will be money.
 */
private tuple[Type, set[Message]] analyzeBinaryExpr(Types types, 
    Expr parent, Expr lhs, Expr rhs) {
  <lhtype, lhmessages> = inferExprType(types, lhs);
  <rhtype, rhmessages> = inferExprType(types, rhs);
  
  if(lhtype == undef() || rhtype == undef())
    return <err(), lhmessages + rhmessages>;
    
  if(lhtype == s() && rhtype == s())
    return <s(), lhmessages + rhmessages>;

  if(lhtype notin types[getName(parent)] || rhtype notin types[getName(parent)])
    return 
      <err(), lhmessages + rhmessages + {invalidTypeMessage(parent@location)}>;
  
  if(lhtype == i() && rhtype == i())
    return <i(), lhmessages + rhmessages>;
  
  if(lhtype in types[getName(parent)] && rhtype in types[getName(parent)])
    return <m(), lhmessages + rhmessages>;

  return <err(), lhmessages + rhmessages>;
}
