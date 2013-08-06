package com.mas.activation.custom.lwc2013

import com.google.inject.Inject
import com.google.inject.Singleton
import com.mas.activation.custom.lwc2013.QuestionnaireLanguage.ComputedItem
import com.mas.activation.custom.lwc2013.QuestionnaireLanguage.ConditionalGroup
import com.mas.activation.custom.lwc2013.QuestionnaireLanguage.ExpressiveFormElement
import com.mas.activation.custom.lwc2013.QuestionnaireLanguage.Form
import com.mas.activation.custom.lwc2013.QuestionnaireLanguage.FormElement
import com.mas.activation.custom.lwc2013.QuestionnaireLanguage.Question
import com.mas.activation.custom.lwc2013.QuestionnaireLanguage.Questionnaire
import com.mas.activation.custom.lwc2013.QuestionnaireLanguage.SimpleFormElement
import com.mas.activation.custom.lwc2013.QuestionnaireLanguage.TypeLiteral
import java.util.List

@Singleton
class StructureExtensions {

	@Inject extension ExpressionExtensions

	def allSimpleFormElements(Form it) {
		filter(typeof(SimpleFormElement))
	}

	def allFormElements(Form it) {
		filter(typeof(FormElement))
	}

	def allQuestions(Form it) {
		filter(typeof(Question))
	}

	def allExpressiveElements(Questionnaire it) {
		eAllContents.filter(typeof(ExpressiveFormElement)).toList
	}

	def private <T> List<T> filter(Form it, Class<T> clazz) {
		eAllContents.filter(clazz).toList
	}

	def TypeLiteral type(SimpleFormElement it) {
		switch it {
			Question:		it.type
			ComputedItem:	it.expression.type
		}
	}

	// (pull-up to ExpressiveFormElement:)
	def dispatch expr(ComputedItem it)		{ expression }
	def dispatch expr(ConditionalGroup it)	{ enablingCondition }

}
