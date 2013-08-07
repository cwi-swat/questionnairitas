package com.mas.lwc2013

import com.mas.lwc2013.QL.BinaryOperatorExpression
import com.mas.lwc2013.QL.BinaryOperators
import com.mas.lwc2013.QL.BooleanNegationExpression
import com.mas.lwc2013.QL.DataTypeLiteral
import com.mas.lwc2013.QL.Expression
import com.mas.lwc2013.QL.FormElement
import com.mas.lwc2013.QL.ValueReference
import com.mas.lwc2013.util.IdMapper

import static com.mas.lwc2013.QL.BinaryOperators.*
import static com.mas.lwc2013.QL.DataTypes.*

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
