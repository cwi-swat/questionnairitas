package com.mas.activation.custom.lwc2013

import com.google.inject.Inject
import com.mas.activation.custom.lwc2013.QuestionnaireLanguage.ComputedItem
import com.mas.activation.custom.lwc2013.QuestionnaireLanguage.ConditionalGroup
import com.mas.activation.custom.lwc2013.QuestionnaireLanguage.DataTypes
import com.mas.activation.custom.lwc2013.QuestionnaireLanguage.ExpressiveFormElement
import com.mas.activation.custom.lwc2013.QuestionnaireLanguage.Form
import com.mas.activation.custom.lwc2013.QuestionnaireLanguage.FormElement
import com.mas.activation.custom.lwc2013.QuestionnaireLanguage.Question
import com.mas.activation.custom.lwc2013.QuestionnaireLanguage.Questionnaire
import com.mas.activation.custom.lwc2013.QuestionnaireLanguage.SimpleFormElement
import nl.dslmeinte.xtend.annotations.ClassParameter
import nl.dslmeinte.xtend.annotations.Initialisation
import nl.dslmeinte.xtend.annotations.ParametrizedInjected

@ParametrizedInjected
class JavascriptGenerator {

	@ClassParameter Questionnaire questionnaire

	@ClassParameter extension IdMapper<FormElement> elementIdMapper
	@ClassParameter IdMapper<Form> formIdMapper
	extension JSExpressionsGenerator jsExpressionsGenerator

	@Initialisation
	def init() {
		this.jsExpressionsGenerator = new JSExpressionsGenerator(elementIdMapper)
	}

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
