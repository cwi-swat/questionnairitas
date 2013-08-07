package com.mas.lwc2013

import com.google.inject.Inject
import com.google.inject.Singleton
import com.mas.lwc2013.QL.BinaryOperatorExpression
import com.mas.lwc2013.QL.BooleanNegationExpression
import com.mas.lwc2013.QL.Expression
import com.mas.lwc2013.QL.ValueReference
import java.util.List

import static com.mas.lwc2013.QL.DataTypes.*
import static com.mas.lwc2013.Severity.*

@Singleton
class TypeChecker {

	@Inject extension ExpressionExtensions
	@Inject extension TypeExtensions

	def Iterable<Issue> check(Expression it) {
		check_
	}

	def private dispatch check_(ValueReference it) {
		noIssues => [ l |
			if( question == null ) {
				l.addIssue(error, '''no question referred by this «eClass.name»''', it)
			}
		]
	}

	def private dispatch Iterable<Issue> check_(BooleanNegationExpression it) {
		(noIssues => [ l |
			if( !operand.type.is(BOOLEAN) ) {
				l.addIssue(error, '''operand of negation must be boolean-typed (is «operand.type.toRegularString»)''', it)
			}
		]) + operand.check
	}

	def private dispatch check_(BinaryOperatorExpression it) {
		(noIssues => [ l |
			if( booleanBinaryOperators.contains(operator) ) {
				leftOperand.checkBooleanNessOperand("left", it, l)
				rightOperand.checkBooleanNessOperand("right", it, l)
			}
			if( leftOperand.type.is(STRING) ) {
				if( !stringOperators.contains(operator) ) {
					l.addIssue(error, '''operator cannot be applied to a string''', it)
				}
				if( !rightOperand.type.is(STRING) ) {
					l.addIssue(error, '''right operand is not string-typed (is «rightOperand.type.toRegularString»)''', it)	// (could make some other types string-coercable?)
				}
			}
			// TODO  numeric stuff
		]) + leftOperand.check + rightOperand.check
	}

	def private checkBooleanNessOperand(Expression it, String description, Expression parentExpr, List<Issue> issuesList) {
		if( !type.is(BOOLEAN) ) {
			issuesList.addIssue(error, '''«description» operand of boolean expression must be boolean-typed (is «type.toRegularString»)''', parentExpr)
		}
	}

	def private dispatch check_(Expression it) {
		noIssues => [ l |
			l.addIssue(warning, '''Expression sub type «eClass.name» not handled by type checker''', it)
		]
	}

	def private List<Issue> noIssues() {
		<Issue>newArrayList
	}

	def private void addIssue(List<Issue> issuesList, Severity severity, CharSequence message, Expression expr) {
		issuesList.add(new Issue(severity, message, expr))
	}

}


@Data
class Issue {

	@Property	Severity severity
	@Property	CharSequence message
	@Property	Expression expr

}

enum Severity {
	error, warning
}

