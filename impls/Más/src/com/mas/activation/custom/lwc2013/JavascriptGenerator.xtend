package com.mas.activation.custom.lwc2013

import com.google.inject.Inject
import com.google.inject.Injector
import com.mas.lwc2013.QL.ComputedItem
import com.mas.lwc2013.QL.ConditionalGroup
import com.mas.lwc2013.QL.DataTypes
import com.mas.lwc2013.QL.ExpressiveFormElement
import com.mas.lwc2013.QL.Form
import com.mas.lwc2013.QL.FormElement
import com.mas.lwc2013.QL.Question
import com.mas.lwc2013.QL.Questionnaire
import com.mas.lwc2013.QL.SimpleFormElement

class JavascriptGenerator {

	new (Questionnaire questionnaire, IdMapper<FormElement> elementIdMapper, IdMapper<Form> formIdMapper, Injector injector) {
		this.questionnaire = questionnaire
		this.elementIdMapper = elementIdMapper
		this.formIdMapper = formIdMapper
		this.jsExpressionsGenerator = new JSExpressionsGenerator(elementIdMapper)
		injector.injectMembers(this)
	}

	val Questionnaire questionnaire
	val extension IdMapper<FormElement> elementIdMapper
	val IdMapper<Form> formIdMapper
	val extension JSExpressionsGenerator jsExpressionsGenerator

	@Inject extension StructureExtensions
	@Inject extension ExpressionExtensions


	def javascript()
		'''
		function mkSimpleFormElement(id, label, inputElt) {
			var divElt = $('<div>').addClass('simpleFormElement');
			var labelElt = $('<label>').attr('for', id)
			divElt.append(labelElt);
			divElt.append(inputElt);
		}

		$(document).ready(function() {
			«FOR f : questionnaire.forms»
				«f.code_»
			«ENDFOR»
		});
		'''


	def private code_(Form it)
		'''
		«FOR e : allFormElements»
			«e.code»
		«ENDFOR»
		function «formIdMapper._id(it)»FilledIn() {
			return( false«/* allQuestions.filter[it.type.canBeUndefined] */» );
		};
		'''

	def private dispatch code(Question it) {
		configureInputType
	}

	def private dispatch code(ComputedItem it)
		// var «_id» = mkSimpleFormElement('«_id»', '«label»', null);
		'''
		«configureInputType»
		«reactivecode»
		'''

	def private dispatch code(ConditionalGroup it) {
		reactivecode
	}


	def private reactivecode(ExpressiveFormElement it)
		'''
		«IF expr != null»
			function update«_Id»() {
				«$_id».«IF it instanceof ConditionalGroup»toggle«ELSE»val«ENDIF»( «expr.asValue» );
			}
			update«_Id»();«/* set proper initial situation */»
			«FOR q : expr.dependentValues»
				«q.$_id».change(update«_Id»);
			«ENDFOR»
		«ENDIF»
		'''



	def private configureInputType(SimpleFormElement it)
		'''
		«IF type().is(DataTypes.MONEY)»
			«$_id».autoNumeric('init');
		«ENDIF»
		'''

}
