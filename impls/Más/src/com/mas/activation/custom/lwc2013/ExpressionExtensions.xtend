package com.mas.activation.custom.lwc2013

import com.google.inject.Singleton
import com.mas.activation.custom.lwc2013.QuestionnaireLanguage.BinaryOperatorExpression
import com.mas.activation.custom.lwc2013.QuestionnaireLanguage.BinaryOperators
import com.mas.activation.custom.lwc2013.QuestionnaireLanguage.BooleanNegationExpression
import com.mas.activation.custom.lwc2013.QuestionnaireLanguage.DataTypeLiteral
import com.mas.activation.custom.lwc2013.QuestionnaireLanguage.DataTypes
import com.mas.activation.custom.lwc2013.QuestionnaireLanguage.EnumerationReferenceLiteral
import com.mas.activation.custom.lwc2013.QuestionnaireLanguage.Expression
import com.mas.activation.custom.lwc2013.QuestionnaireLanguage.Question
import com.mas.activation.custom.lwc2013.QuestionnaireLanguage.QuestionnaireLanguageFactory
import com.mas.activation.custom.lwc2013.QuestionnaireLanguage.TypeLiteral
import com.mas.activation.custom.lwc2013.QuestionnaireLanguage.ValueReference
import java.util.Set

import static com.mas.activation.custom.lwc2013.QuestionnaireLanguage.BinaryOperators.*
import static com.mas.activation.custom.lwc2013.QuestionnaireLanguage.DataTypes.*
import static java.util.EnumSet.*

@Singleton
class ExpressionExtensions {

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


	val eFactory = QuestionnaireLanguageFactory.eINSTANCE

	def private typeLiteral(DataTypes dataType) {
		eFactory.createDataTypeLiteral => [ it.dataType = dataType ]
	}


	def is(TypeLiteral it, DataTypes testDataType) {
		switch it {
			DataTypeLiteral:	it.dataType == testDataType
			default:			false
		}
	}


	def private canBeUndefined(DataTypes it) {
		it != BOOLEAN
	}

	def canBeUndefined(TypeLiteral it) {
		switch it {
			DataTypeLiteral:				it.dataType.canBeUndefined
			EnumerationReferenceLiteral:	true
		}
	}


	def toRegularString(TypeLiteral it) {
		switch it {
			DataTypeLiteral:				'''«it.dataType.literal»-data typed'''
			EnumerationReferenceLiteral:	'''«it.enumeration.name»-enumeration typed'''
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
