package com.mas.activation.custom.lwc2013

import com.mas.activation.custom.lwc2013.QuestionnaireLanguage.BinaryOperatorExpression
import com.mas.activation.custom.lwc2013.QuestionnaireLanguage.BinaryOperators
import com.mas.activation.custom.lwc2013.QuestionnaireLanguage.BooleanNegationExpression
import com.mas.activation.custom.lwc2013.QuestionnaireLanguage.DataTypeLiteral
import com.mas.activation.custom.lwc2013.QuestionnaireLanguage.Expression
import com.mas.activation.custom.lwc2013.QuestionnaireLanguage.FormElement
import com.mas.activation.custom.lwc2013.QuestionnaireLanguage.ValueReference

import static com.mas.activation.custom.lwc2013.QuestionnaireLanguage.BinaryOperators.*
import static com.mas.activation.custom.lwc2013.QuestionnaireLanguage.DataTypes.*

@Data
class JSExpressionsGenerator {

	@Property extension IdMapper<FormElement> elementIdMapper

	def CharSequence asValue(Expression it) {
		switch it {
			ValueReference:
				'''«question.$_id».«
					switch t: question.type {
						DataTypeLiteral: switch t.dataType {
							case BOOLEAN:	"prop('checked')"
							case MONEY:		"autoNumeric('get')"
							default:		"val()"
						}
						default:			"val()"
					}
				»'''
			BinaryOperatorExpression:	'''((«leftOperand.asValue») «operator.asJS» («rightOperand.asValue»))'''
			BooleanNegationExpression:	'''(!(«operand.asValue»))'''
			case null:					throw new NullPointerException('''expression instance is null in #asValue''')
			default:					throw new UnsupportedOperationException('''expression type «eClass.name» not yet handled by #asValue''')
		}
	}


	def dispatch asDefined(ValueReference it) {
		switch t: question.type {
			DataTypeLiteral: switch t.dataType {
				case BOOLEAN:	"true"
				case MONEY:		'''(«asValue» !== null)'''
				default:		'''(«asValue» !== null)'''
			}
			default:			'''(«asValue» !== null)'''
		}
	}

	def dispatch asDefined(BooleanNegationExpression it)
		'''true'''

	def dispatch CharSequence asDefined(Expression it) {
		throw new UnsupportedOperationException('''expression type «eClass.name» not yet handled by #isDefined''')
	}


	def private asJS(BinaryOperators it) {
		switch it {
			case SMALLER_THAN:			"<"
			case GREATER_THAN:			">"
			case GREATER_THAN_EQUAL_TO:	">="
			case SMALLER_THAN_EQUAL_TO:	"<="
			case UNEQUAL_TO:			"!=="
			case EQUAL_TO:				"==="
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
