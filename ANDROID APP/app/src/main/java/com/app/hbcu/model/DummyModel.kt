package com.app.hbcu.model

class DummyModel {

    var name: String? = null
    var time: String? = null
    var detail: String? = null
    var product_id: String? = null
    var prdt_image: String? = null
    var qty = 0.0
    var price = 0.0

    constructor(name: String?, time: String?, detail: String?) {
        this.name = name
        this.time = time
        this.detail = detail
    }
}