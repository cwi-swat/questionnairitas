package com.mas.lwc2013.util

import com.mas.lwc2013.QL.BinaryOperators
import com.mas.lwc2013.QL.DataTypes
import com.mas.lwc2013.QL.Documented
import com.mas.lwc2013.QL.Enumeration
import com.mas.lwc2013.QL.EnumerationLiteral
import com.mas.lwc2013.QL.Expression
import com.mas.lwc2013.QL.Form
import com.mas.lwc2013.QL.FormElement
import com.mas.lwc2013.QL.Named
import com.mas.lwc2013.QL.QLFactory
import com.mas.lwc2013.QL.SequentialComposition
import com.mas.lwc2013.QL.SimpleFormElement
import com.mas.lwc2013.QL.TypeLiteral
import java.util.List
import java.util.Map
import org.eclipse.emf.common.util.EList
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.EStructuralFeature.Setting
import org.eclipse.emf.ecore.InternalEObject
import org.json.JSONArray
import org.json.JSONObject

/**
 * A quickly hand-coded unmarshaller for the JSON which is the serialization of QL models.
 * <p>
 * I didn't use the original unmarshaller (as-is) because it's quite tied to the Más code base.
 */
class Unmarshaller {

	new(JSONArray json) {
		this.result = json.unmarshall as Iterable<?>
		computeSymbolTable
		printDebuggingInfo
		doLinking
	}

	public val Iterable<?> result

	def private dispatch Iterable<?> unmarshall(JSONArray it)	{ map[unmarshall] }
	def private dispatch Object unmarshall(JSONObject it)		{ unmarshallObject }
	def private dispatch Object unmarshall(Object it)			{ it }

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
					preLink('enumeration', o.getString('enumeration'))
					preLink('literal', o.getString('literal'))
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
					preLink('question', o.getString('question'))
				]
			}
			default:
				throw new IllegalArgumentException('''don't know how to unmarshall instance of "«clazz»"''')
		}
	}

	def private populateForDocumented(Documented it, JSONObject o)							{ documentation = o.optString('documentation') }
	def private populateForExpression(Expression it, JSONObject o)							{ /* (nothing) */ }
	def private populateForExpressiveFormElement(FormElement it, JSONObject o)				{ populateForFormElement(o) }
	def private populateForFormElement(FormElement it, JSONObject o)						{ /* (nothing) */ }
	def private populateForNamed(Named it, JSONObject o) {
		name = o.getString('name')
	}
//	def private populateForOptionallyNamed(OptionallyNamed it, JSONObject o)				{ name = o.optString('name') }
	def private populateForSequentialComposition(SequentialComposition it, JSONObject o)	{ elements += o.opt('elements').asMany.map[unmarshall as FormElement] }
	def private populateForSimpleFormElement(SimpleFormElement it, JSONObject o) {
		populateForFormElement(o)
		populateForNamed(o)
		label = o.getString('label')
	}
	def private populateForTypeLiteral(TypeLiteral it, JSONObject o)						{ /* (nothing) */ }

	val eFactory = QLFactory.eINSTANCE

	def private <U, V> Iterable<V> map(JSONArray jsonArray, (U)=>V function) {
		(0..(jsonArray.length -1)).map[ i |
			function.apply(jsonArray.get(i) as U) as V
		].toList	// force evaluation
	}

	def private dispatch JSONArray asMany(JSONArray it)	{ it }
	def private dispatch asMany(Object o)				{ new JSONArray => [ if( o != null ) put(o) ] }


	/*
	 * +--------------+
	 * | symbol table |
	 * +--------------+
	 */

	def private computeSymbolTable() {
		this.result.forEach[
			switch it {
				EObject:	eAllContents.filter(typeof(Named)).forEach[addToSymbolTable]
			}
		]
	}

	val Map<String, List<Named>> symbolTable = newHashMap

	def private addToSymbolTable(Named it) {
		var list = symbolTable.get(qName)
		if( list == null ) {
			list = newArrayList
			symbolTable.put(qName, list)
		}
		list += it
	}

	def private qName(Named it) {
		var EObject current = it
		var result = ""
		while( current != null ) {
			switch current {
				Named:	result = "/" + current.name + result
			}
			current = current.eContainer
		}
		result.substring(1)
	}


	/*
	 * +--------------------+
	 * | linking (settings) |
	 * +--------------------+
	 */

	val settingsToLink = <PreLink>newArrayList

	def private preLink(EObject eObject, String featureName, String qName) {
		settingsToLink += new PreLink((eObject as InternalEObject).eSetting(eObject.eClass.getEStructuralFeature(featureName)), qName)
	}

	def private doLinking() {
		settingsToLink.forEach[
			val feature = getSetting.getEStructuralFeature
			val refEType = (feature as EReference).getEReferenceType

			val candidatesByQName = symbolTable.get(getQualifiedName)
			if( candidatesByQName == null ) {
				System.err.println('''error: no targets of any type for qualified name "«getQualifiedName»"''')
				return
			}

			val candidatesByType = candidatesByQName.filter[ refEType.isSuperTypeOf(eClass) ]
			if( candidatesByType.size != 1 ) {
				System.err.println('''error: «candidatesByType.size» candidate targets for reference of type «feature.getEType.name» to "«getQualifiedName»"''')
				return
			}

			val value = candidatesByType.head
			if( feature.many ) {
				(getSetting.getEObject.eGet(getSetting.getEStructuralFeature, false) as EList<EObject>) += value
			} else {
				getSetting.set(value)
			}
		]

	}

	def private printDebuggingInfo() {
		println('''symbol table:''')
		symbolTable.forEach[ qName, list |
			println('''	"«qName»": «list.map['''<«eClass.name»> "«name»"''']»''')
		]
		println
		println('''settings-to-link:''')

		settingsToLink.forEach[
			val feature = getSetting.getEStructuralFeature
			val refEType = (feature as EReference).getEReferenceType

			println('''	«feature.getEContainingClass.name»#«feature.name» --> <«refEType.name»>"«getQualifiedName»"''')
		]

		println
		println
	}

}


@Data
final class PreLink {

	@Property Setting setting;
	@Property String qualifiedName;

	override String toString() {	// for debugging purposes
		'''<«getSetting.getEStructuralFeature.getEType.name»> "«getQualifiedName»"'''
	}

}

