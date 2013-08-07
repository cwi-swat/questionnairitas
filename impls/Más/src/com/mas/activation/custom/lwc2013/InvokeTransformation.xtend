package com.mas.activation.custom.lwc2013

import com.google.inject.Guice
import com.google.inject.Inject
import java.io.File
import java.io.FileInputStream
import org.apache.commons.io.FileUtils
import org.json.JSONArray
import org.json.JSONTokener

class InvokeTransformation {

	def static void main(String[] args) {
		Guice.createInjector.getInstance(typeof(InvokeTransformation)).run
	}

	@Inject extension QuestionnaireLanguageWebGenerator

	val modelName = 'QL_example'

	def private run() {
		FileUtils.write(new File('''web/«modelName».html'''), persistedModel.generate)
		println('''generated HTML for: «modelName»''')
	}

	def private persistedModel() {
		new JSONArray(new JSONTokener(new FileInputStream(new File('''models/«modelName».json'''))))
	}

}
