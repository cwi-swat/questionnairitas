package com.mas.lwc2013

import com.google.inject.Inject
import com.google.inject.Singleton
import com.mas.lwc2013.QL.ComputedItem
import com.mas.lwc2013.QL.ConditionalGroup
import com.mas.lwc2013.QL.Form
import com.mas.lwc2013.QL.FormElement
import com.mas.lwc2013.QL.Question
import com.mas.lwc2013.QL.SimpleFormElement
import com.mas.lwc2013.QL.TypeLiteral
import java.util.List

/**
 * Xtensions for dealing with QL instances on a structural level.
 */
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

	def private <T> List<T> filter(Form it, Class<T> clazz) {
		eAllContents.filter(clazz).toList
	}

	def TypeLiteral type(SimpleFormElement it) {
		switch it {
			Question:		it.type
			ComputedItem:	it.expression.type
		}
	}

	// (pulled-up to ExpressiveFormElement:)
	def dispatch expr(ComputedItem it)		{ expression }
	def dispatch expr(ConditionalGroup it)	{ enablingCondition }

}
