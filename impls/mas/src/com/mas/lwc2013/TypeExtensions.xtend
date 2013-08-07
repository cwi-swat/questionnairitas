package com.mas.lwc2013

import com.google.inject.Singleton
import com.mas.lwc2013.QL.DataTypeLiteral
import com.mas.lwc2013.QL.DataTypes
import com.mas.lwc2013.QL.EnumerationReferenceLiteral
import com.mas.lwc2013.QL.QLFactory
import com.mas.lwc2013.QL.TypeLiteral

/**
 * Xtensions for working with type information.
 */
@Singleton
class TypeExtensions {

	val eFactory = QLFactory.eINSTANCE

	def typeLiteral(DataTypes dataType) {
		eFactory.createDataTypeLiteral => [ it.dataType = dataType ]
	}


	def is(TypeLiteral it, DataTypes testDataType) {
		switch it {
			DataTypeLiteral:	it.dataType == testDataType
			default:			false
		}
	}


	def private canBeUndefined(DataTypes it) {
		it != Boolean
	}

	def canBeUndefined(TypeLiteral it) {
		switch it {
			DataTypeLiteral:				it.dataType.canBeUndefined
			EnumerationReferenceLiteral:	true
		}
	}


	def toRegularString(TypeLiteral it) {
		switch it {
			DataTypeLiteral:				'''«it.dataType.literal»-data typed'''
			EnumerationReferenceLiteral:	'''«it.enumeration.name»-enumeration typed'''
		}
	}

}
