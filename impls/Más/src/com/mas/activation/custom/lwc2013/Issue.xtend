package com.mas.activation.custom.lwc2013

import com.mas.lwc2013.QL.Expression

@Data
class Issue {

	@Property	Severity severity
	@Property	CharSequence message
	@Property	Expression expr

}
