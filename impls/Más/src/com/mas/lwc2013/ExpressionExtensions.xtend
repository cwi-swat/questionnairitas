package com.mas.lwc2013

import com.google.inject.Inject
import com.google.inject.Singleton
import com.mas.lwc2013.QL.BinaryOperatorExpression
import com.mas.lwc2013.QL.BinaryOperators
import com.mas.lwc2013.QL.BooleanNegationExpression
import com.mas.lwc2013.QL.Expression
import com.mas.lwc2013.QL.Question
import com.mas.lwc2013.QL.TypeLiteral
import com.mas.lwc2013.QL.ValueReference
import java.util.Set

import static com.mas.lwc2013.QL.BinaryOperators.*
import static com.mas.lwc2013.QL.DataTypes.*
import static java.util.EnumSet.*

/**
 * Xtensions dealing with QL expressions, such as dependency, type calculation and some verbosity.
 */
@Singleton
class ExpressionExtensions {

	@Inject extension TypeExtensions

	def Set<Question> dependentValues(Expression expr) {
		switch expr {
			BinaryOperatorExpression:	<Question>newHashSet => [ addAll(expr.leftOperand.dependentValues); addAll(expr.rightOperand.dependentValues) ]
			BooleanNegationExpression:	expr.operand.dependentValues
			ValueReference:				newHashSet(expr.question)
		}
	}


	public val booleanBinaryOperators = of(AND, OR)
	public val equalityOperators = of(UNEQUAL_TO, EQUAL_TO)
	public val comparisonOperators = of(SMALLER_THAN, GREATER_THAN, GREATER_THAN_EQUAL_TO, SMALLER_THAN_EQUAL_TO, UNEQUAL_TO, EQUAL_TO)
	public val stringOperators = of(UNEQUAL_TO, EQUAL_TO, ADDITION)

	public val numericTypes = of(INTEGER, DECIMAL, MONEY)

	val booleanYieldingBinaryOperators = range(SMALLER_THAN, OR)
	val arithmeticBinaryOperators = range(ADDITION, DIVISION)

	def TypeLiteral type(Expression it) {
		switch it {
			BinaryOperatorExpression:
				switch o: it.operator {
					case booleanYieldingBinaryOperators.contains(o):	BOOLEAN.typeLiteral
					case arithmeticBinaryOperators.contains(o):			it.leftOperand.type
					case STRING_CONCATENATION:							STRING.typeLiteral
				}
			BooleanNegationExpression:	BOOLEAN.typeLiteral
			ValueReference:				it.question.type
		}
	}


	def CharSequence toRegularString(Expression it) {
		switch it {
			ValueReference:				'''$(«it.question.name»)'''
			BooleanNegationExpression:	'''!(«it.operand.toString»)'''
			BinaryOperatorExpression:	'''(«it.leftOperand.toRegularString» «it.operator.toRegularString» «it.rightOperand.toRegularString»)'''
		}
	}

	def private toRegularString(BinaryOperators it) {
		switch it {
			case SMALLER_THAN:			"<"
			case GREATER_THAN:			">"
			case GREATER_THAN_EQUAL_TO:	">="
			case SMALLER_THAN_EQUAL_TO:	"<="
			case UNEQUAL_TO:			"!="
			case EQUAL_TO:				"=="
			case AND:					"&&"
			case OR:					"||"
			case ADDITION:				"+"
			case SUBTRACTION:			"-"
			case MULTIPLICATION:		"*"
			case DIVISION:				"/"
			case STRING_CONCATENATION:	"+"
		}
	}

}
