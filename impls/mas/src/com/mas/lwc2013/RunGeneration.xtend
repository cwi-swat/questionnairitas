package com.mas.lwc2013

import com.google.inject.Guice
import com.google.inject.Inject
import java.io.File
import java.io.FileInputStream
import org.apache.commons.io.FileUtils
import org.json.JSONArray
import org.json.JSONTokener

/**
 * Main class to kick off generation for QL instances.
 */
class RunGeneration {

	def static void main(String[] args) {
		val that = Guice.createInjector.getInstance(typeof(RunGeneration))
		that.modelName = args.get(0) ?: 'QL_example'
		that.run
	}

	@Inject extension QLWebGenerator

	public String modelName

	def private run() {
		FileUtils.write(new File('''web/«modelName».html'''), loadModel.generate)
		println('''generated HTML for: «modelName»''')
	}

	def private loadModel() {
		new JSONArray(new JSONTokener(new FileInputStream(new File('''models/«modelName».json'''))))
	}

}
