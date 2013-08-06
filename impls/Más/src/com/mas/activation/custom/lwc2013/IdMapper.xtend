package com.mas.activation.custom.lwc2013

import java.util.Map

class IdMapper<T> {

	val String prefix

	new(String prefix) {
		this.prefix = prefix
	}


	var currentId = 0

	val Map<T, Integer> idMap = newHashMap

	def id(T it) {
		switch id_: idMap.get(it) {
			case null: 	{
				currentId = currentId + 1
				idMap.put(it, currentId)
				currentId
			}
			default:	id_
		}
	}


	/*
	 * +------------------------------------------+
	 * | convenience functions for use in HTML/JS |
	 * +------------------------------------------+
	 * 
	 * TODO  add proper escaping
	 */

	def _id(T it)	{ prefix + id }
	def _Id(T it)	{ prefix.toFirstUpper + id }
	def $_id(T it)	'''$('#«_id»')'''

}
