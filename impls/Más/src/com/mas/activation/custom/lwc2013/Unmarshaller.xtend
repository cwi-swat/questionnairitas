package com.mas.activation.custom.lwc2013

import com.google.inject.Singleton
import com.mas.activation.custom.lwc2013.QuestionnaireLanguage.BinaryOperators
import com.mas.activation.custom.lwc2013.QuestionnaireLanguage.DataTypes
import com.mas.activation.custom.lwc2013.QuestionnaireLanguage.Documented
import com.mas.activation.custom.lwc2013.QuestionnaireLanguage.Enumeration
import com.mas.activation.custom.lwc2013.QuestionnaireLanguage.EnumerationLiteral
import com.mas.activation.custom.lwc2013.QuestionnaireLanguage.Expression
import com.mas.activation.custom.lwc2013.QuestionnaireLanguage.Form
import com.mas.activation.custom.lwc2013.QuestionnaireLanguage.FormElement
import com.mas.activation.custom.lwc2013.QuestionnaireLanguage.Named
import com.mas.activation.custom.lwc2013.QuestionnaireLanguage.QuestionnaireLanguageFactory
import com.mas.activation.custom.lwc2013.QuestionnaireLanguage.SequentialComposition
import com.mas.activation.custom.lwc2013.QuestionnaireLanguage.SimpleFormElement
import com.mas.activation.custom.lwc2013.QuestionnaireLanguage.TypeLiteral
import org.json.JSONArray
import org.json.JSONObject

@Singleton
class Unmarshaller {

	def dispatch Iterable<?> unmarshall(JSONArray it)	{ map[unmarshall] }
	def dispatch unmarshall(JSONObject it)				{ unmarshallObject }
	def dispatch unmarshall(Object it)					{ it }

	def private Object unmarshallObject(JSONObject o) {
		switch clazz: o.getString("_class") {
			case "Binary Operator Expression": {
				eFactory.createBinaryOperatorExpression => [
					populateForExpression(o)
					leftOperand = o.get('leftOperand').unmarshall as Expression
					rightOperand = o.get('rightOperand').unmarshall as Expression
					operator = BinaryOperators.getByName(o.getString('operator'))
				]
			}
			case "Boolean Negation Expression": {
				eFactory.createBooleanNegationExpression => [
					populateForExpression(o)
					operand = o.get('operand').unmarshall as Expression
				]
			}
			case "Computed Item": {
				eFactory.createComputedItem => [
					populateForSimpleFormElement(o)
					populateForExpressiveFormElement(o)
					expression = o.get('expression').unmarshall as Expression
				]
			}
			case "Conditional Group": {
				eFactory.createConditionalGroup => [
					populateForSequentialComposition(o)
					populateForFormElement(o)
					populateForExpressiveFormElement(o)
					enablingCondition = o.get('enabling condition').unmarshall as Expression
				]
			}
			case "DataType Literal": {
				eFactory.createDataTypeLiteral => [
					dataType = DataTypes.getByName(o.getString('data type'))
				]
			}
			case "Enumeration": {
				eFactory.createEnumeration => [
					populateForNamed(o)
					literals += o.get('literals').asMany.map[unmarshall as EnumerationLiteral]
				]
			}
			case "Enumeration Literal": {
				eFactory.createEnumerationLiteral => [
					populateForNamed(o)
				]
			}
			case "Enumeration Reference Literal": {
				eFactory.createEnumerationReferenceLiteral => [
					populateForTypeLiteral(o)
					// TODO  resolve references to 'enumeration' and 'literal' (within the former)
				]
			}
			case "Form": {
				eFactory.createForm => [
					populateForNamed(o)
					populateForSequentialComposition(o)
				]
			}
			case "Question": {
				eFactory.createQuestion => [
					populateForSimpleFormElement(o)
					type = o.get('type').unmarshall as TypeLiteral
				]
			}
			case "Questionnaire": {
				eFactory.createQuestionnaire => [
					populateForDocumented(o)
					enumerations += o.opt('enumerations').asMany.map[unmarshall as Enumeration]
					forms += o.opt('forms').asMany.map[unmarshall as Form] ?: emptyList
				]
			}
			case "Value Reference": {
				eFactory.createValueReference => [
					populateForExpression(o)
					// TODO  resolve reference to 'question'
				]
			}
			default:
				throw new IllegalArgumentException('''don't know how to unmarshall instance of "«clazz»"''')
		}
	}

	def private populateForDocumented(Documented it, JSONObject o)							{ documentation = o.optString('name') }
	def private populateForExpression(Expression it, JSONObject o)							{ /* (nothing) */ }
	def private populateForExpressiveFormElement(FormElement it, JSONObject o)				{ populateForFormElement(o) }
	def private populateForFormElement(FormElement it, JSONObject o)						{ /* (nothing) */ }
	def private populateForNamed(Named it, JSONObject o)									{ name = o.getString('name') }
//	def private populateForOptionallyNamed(OptionallyNamed it, JSONObject o)				{ name = o.optString('name') }
	def private populateForSequentialComposition(SequentialComposition it, JSONObject o)	{ elements += o.opt('elements').asMany.map[unmarshall as FormElement] }
	def private populateForSimpleFormElement(SimpleFormElement it, JSONObject o) {
		populateForFormElement(o)
		populateForNamed(o)
		label = o.getString('label')
	}
	def private populateForTypeLiteral(TypeLiteral it, JSONObject o)						{ /* (nothing) */ }

	val eFactory = QuestionnaireLanguageFactory.eINSTANCE

	def private <U, V> Iterable<V> map(JSONArray jsonArray, (U)=>V function) {
		(0..(jsonArray.length -1)).map[ i |
			function.apply(jsonArray.get(i) as U) as V
		]
	}

	def private dispatch JSONArray asMany(JSONArray it)	{ it }
	def private dispatch asMany(Object o)				{ new JSONArray => [ if( o != null ) put(o) ] }

}
