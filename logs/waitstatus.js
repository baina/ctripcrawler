! function($) {
	online.create("service.IndexService", {
		options: {
			loading: "loading",
			exgratiaCache: {},
			exgratiaUrl: "subPage/AjaxFlightCheapInfo.aspx",
			domain: document.getElementById("CurrentFirstDomain").value,
			msg: online.msg,
			searchWait: null,
			drpFlightWay: $("#search_type input").length > 0 ? $("#search_type input:radio[name='ctl00$MainContentPlaceHolder$drpFlightWay']") : null
		},
		methods: {
			initialize: function(a) {
				if (this.info(), this.extend(this, a), this.processThDcity(), this.gocity = $("#city_departure").length > 0 ? online.first($("#city_departure")[0]).getAttribute("online_code") : "", this.currentTocity = $("#city_arrival").length > 0 ? $("#city_arrival a.current")[0] : null, this.online_exgratiaData = $("#online_exgratiaData")[0] || null, this.tocity = this.currentTocity && this.currentTocity.getAttribute("online_code"), $.cookie.get("online_cityname")) {
					var b = online.toJson(unescape($.cookie.get("online_cityname")));
					online.first($("#city_departure")[0]).innerHTML = b.cityname, online.first($("#city_departure")[0]).setAttribute("online_code", b.citycode), this.gocity = b.citycode
				}
				this.online_exgratiaData && this.goToCity(this.online_exgratiaData, this.gocity, this.tocity), this.voyageType = this.voyageType(), this.bindEvent()
			},
			dingyue: function(a) {
				var b = document.getElementById("mail_state_sucess"),
					c = this;
				if (!a || "undefined" == typeof a) return void(b.style.display = "none");
				var d = document.getElementById("mailSubscribe") || arguments[1],
					e = /^[^@\s]+@[^@\.\s]+(\.[^@\.\s]+)+$/,
					f = d.value.trim();
				!online.isNull(d) && e.test(f) ? (a += -1 != a.indexOf("?") ? "&email=" + f : "?email=" + f, $.ajax(a, {
					onsuccess: function(a) {
						a = a.responseText, a && "success" == a ? b.style.display = "block" : alert(c.msg.ERROR_DINGYUE[1])
					}
				})) : online.registerMod.validate(d, c.msg.ERROR_DINGYUE[0])
			},
			inteFlightSF: function() {
				try {
					var a = this.drpFlightWay.filter(":checked")[0].value.toLowerCase(),
						b = "m" == a ? "ctl00_MainContentPlaceHolder_txtBeginAddress1" : "ctl00_MainContentPlaceHolder_txtDCity",
						c = this;
					setTimeout(function() {
						try {
							online.registerMod.inits.address[b].method("focus", {
								isHidden: !0,
								isSelected: !0
							})
						} catch (a) {
							setTimeout(c.inteFlightSF.bind(c), 200)
						}
					}, "m" == a ? 500 : 1)
				} catch (d) {}
			},
			removeCookie: function(a, b, c) {
				document.cookie = a + "=" + (b ? "; path=" + b : "") + (c ? "; domain=" + c : "") + "; expires=" + new Date(0)
			},
			voyageType: function() {
				var a = function(a, b, c, d) {
					return -c * ((a = a / d - 1) * a * a * a - 1) + b
				}, b = online.registerMod.searchBoxVals.multipleRound,
					c = function(b) {
						var c = $("#box_search")[0],
							d = -252,
							e = 562,
							f = 10,
							g = 0,
							h = null;
						online["m" == b ? "addClass" : "removeClass"](c, "multiple_search"), "m" == b && (c.style.width = "310px", c.style.display = "", d = 252, e = 310), "m" != b && parseInt($(c).css("width")) <= 310 || ! function() {
							clearTimeout(h), f > g && (c.style.width = Math.round(a(g++, e, d, f)) + "px", timeobj = setTimeout(arguments.callee, 1))
						}()
					}, d = function() {
						document.getElementById("age_type_tip").style.display = 1 == online.$get("selUserType", !0).selectedIndex ? "" : "none"
					};
				return online.$get("selUserType", !0).onchange = d, b && "M" != b && ($("#ctl00_MainContentPlaceHolder_flight_way_" + b.toLowerCase())[0].checked = !0, b = ""),
				function() {
					if (null != this.drpFlightWay) {
						var a = this.drpFlightWay.filter(":checked")[0].value.toLowerCase();
						if (this.resetCssByXQD(), $("#single_line").css("display", "m" != a ? "block" : "none"), $("#return_li").css("display", "m" == a || "s" == a ? "none" : "block"), $("#searchHotel").css("display", "m" == a || "s" == a ? "none" : ""), $("#multiple_div").css("display", "m" == a ? "block" : "none"), $("#searchHotel").css("display", "m" == a || "s" == a ? "none" : ""), $("#flight_choose").length > 0 && ($("#flight_choose")[0].style.display = "m" == a ? "none" : ""), $("#label_flight").length > 0 && ($("#label_flight")[0].style.display = "m" == a ? "none" : ""), c(a), "m" != a && (online.registerMod.searchBoxVals.multipleRound = a.toUpperCase()), d(), "d" == a) {
							var b = $("#ctl00_MainContentPlaceHolder_txtADatePeriod1"),
								e = $("#ctl00_MainContentPlaceHolder_txtDDatePeriod1"),
								f = e.value().toDate();
							null == f && (f = (new Date).toDate()), "" != b.value() && b.value().toDate() < f && (b.value(""), b[0].focus())
						}
						this.inteFlightSF()
					}
				}
			},
			resetCssByXQD: function() {
				if ($.browser.isIE6) {
					var a = document.getElementById("xqdTipsDiv");
					a && (a.style.display = "none", setTimeout(function() {
						a.style.position = "absolute", a.style.left = "5px", a.style.bottom = "5px", a.style.display = "block"
					}, 200))
				}
			},
			goToCity: function(a, b, c) {
				var d = online.first(a),
					e = b + "-" + c,
					f = $("#tloading"),
					g = this;
				if (this.exgratiaCache[e]) $(d).html(this.exgratiaCache[e]), $(a).find("[mod='jmpInfo']").each(function(a) {
					online.registerMod.register_jmpInfo($(a))
				}), f.hide(), $(a).show();
				else {
					f.show(), $(a).hide();
					var h = "startCityName=" + b + "&endCityName=" + c;
					h = "-1" != this.exgratiaUrl.indexOf("?") ? this.exgratiaUrl + "&" + h : this.exgratiaUrl + "?" + h, $.ajax(h, {
						cache: 0,
						onsuccess: function(b) {
							b = b.responseText, f.hide(), "" != b && ($(d).html(g.exgratiaCache[e] = b), $(a).show(), $(a).find("[mod='jmpInfo']").each(function(a) {
								online.registerMod.register_jmpInfo($(a))
							}))
						}
					})
				}
			},
			doQueryString: function() {
				var a = $("#hdn_search_dcity")[0].value,
					b = $("#hdn_search_acity")[0].value,
					c = $("#hdn_search_dcityid")[0].value,
					d = $("#hdn_search_acityid")[0].value,
					e = $("#hdn_search_depart")[0].value,
					f = $("#hdn_search_arrive")[0].value,
					g = $("#hdn_search_flighttype")[0].value;
				"" == a && (a = ""), "" != a && ($("#ctl00_MainContentPlaceHolder_txtDCity")[0].value = a, $("#ctl00_MainContentPlaceHolder_txtDCityID")[0].value = c), "" == b && (b = ""), "" != b && ($("#ctl00_MainContentPlaceHolder_dest_city_1")[0].value = b, $("#ctl00_MainContentPlaceHolder_txtDestcityID")[0].value = d), "" != e && ($("#ctl00_MainContentPlaceHolder_txtDDatePeriod1")[0].value = e), "" == f && (f = ""), "" != f && ($("#ctl00_MainContentPlaceHolder_txtADatePeriod1")[0].value = f), "" != g && ("d" == g && ($("#ctl00_MainContentPlaceHolder_flight_way_d")[0].checked = !0), "s" == g && ($("#ctl00_MainContentPlaceHolder_flight_way_s")[0].checked = !0), "o" == g && ($("#ctl00_MainContentPlaceHolder_flight_way_o")[0].checked = !0))
			},
			getCityNameFromCode: function(a) {
				return this.msg.cityCode[a] ? this.msg.cityCode[a] : this.msg.cityCode.OTHER
			},
			processThDcity: function() {
				if ("undefined" != typeof thDCity && thDCity) {
					for (var a = thDCity.split(","), b = [], c = 0; c < a.length; c++) "HKG" != a[c] && b.push('<a online_code="' + a[c] + '" href="javascript:void(0);">' + this.getCityNameFromCode(a[c]) + "</a>");
					$("#city_departure_more")[0].innerHTML = b.join("")
				}
			},
			keydownByCityInput: function(a) {
				var b = a.target,
					c = online.$get("btnSearchFlight", !0),
					d = isNaN(a.keyCode) ? a.charCode : a.keyCode;
				if ("13" == d) {
					if (a.preventDefault ? a.preventDefault() : a.returnValue = !1, "INPUT" == b.nodeName && "radio" == b.getAttribute("type").toLowerCase()) return $("#" + ("M" != b.value ? "ctl00_MainContentPlaceHolder_txtDCity" : "ctl00_MainContentPlaceHolder_txtBeginAddress1"))[0].focus(), !1;
					if ("input" == b.nodeName.toLowerCase() && "submit" == b.getAttribute("type")) return c.click(), !1;
					if ("input" == b.nodeName.toLowerCase()) {
						var e = online.next(null != $(b).parents("label")[0] ? $(b).parents("label")[0] : $(b).parents("li")[0]);
						if (null != $(b).parents("label")[0] && (null == e || "LABEL" != e.nodeName))
							for (e = online.next($(b).parents("li")[0]);
								"none" == $(e).css("display");) e = online.next(e);
						if (null != e && "none" != $(e).css("display")) {
							var f = $(e).find("input");
							if (f.length > 0) return setTimeout(function() {
								f[0].select(), f[0].focus()
							}, 1), !1
						}
						b.blur(), c["M" == this.drpFlightWay.filter(":checked")[0].value ? "click" : "click"]()
					} else online.$get("btnSearchFlight", !0).focus()
				}
			},
			bindEvent: function() {
				var a = this;
				$("#city_menu").length > 0 && $("#city_menu").bind("mousedown", function(b) {
					if (b = b.target, "A" == b.nodeName && "city_departure_now" == b.className) return void(online.next(b).style.display = "none" == online.next(b).style.display ? "block" : "none");
					if ("A" == b.nodeName && "city_departure_more" == $(b).parents("div")[0].className) {
						var c = online.prev($(b).parents("div")[0]);
						return c.innerHTML = b.innerHTML + a.msg.tipText[12], $.cookie.set("online_cityname", null, '{cityname:"' + c.innerHTML.trim() + '",citycode:"' + b.getAttribute("online_code") + '"}', {
							expires: 10
						}), c.setAttribute("online_code", b.getAttribute("online_code")), a.gocity = b.getAttribute("online_code"), $(b).parents("div")[0].style.display = "none", void a.goToCity(a.online_exgratiaData, a.gocity, a.tocity)
					}
					return "A" == b.nodeName && $(b).parents("dl")[0] && "city_arrival" == $(b).parents("dl")[0].className ? (b.className = "current", null != a.currentTocity && a.currentTocity != b && (a.currentTocity.className = ""), a.currentTocity = b, a.tocity = b.getAttribute("online_code"), void a.goToCity(a.online_exgratiaData, a.gocity, a.tocity)) : void 0
				}), $("#city_departure").length > 0 && $("#city_departure").bind("mouseout", function(a) {
					online.checkHover(a, this) && ($("#city_departure_more")[0].style.display = "none")
				}), $("#online_fltarea").length > 0 && $("#online_fltarea").bind("click", function() {
					this.ajaxData || $.ajax("AjaxRequest/GetCmsContent.ashx", {
						onsuccess: function(a, b) {
							b && "" != b && $("#sales_list .sales_list2").html(b)
						}
					})
				}), $("#online_gotocity").length > 0 && $("#online_gotocity").bind("click", function() {
					a.goToCity(a.online_exgratiaData, a.gocity, a.tocity)
				}), $(this.online_exgratiaData).length > 0 && $(this.online_exgratiaData).bind("mousedown", function(b) {
					if (b = b.target, "INPUT" == b.nodeName && "base_btns5" == b.className && "button" == b.type) {
						var c = online.toJson(b.getAttribute("params")),
							d = c.endDate.split("-");
						online.loadJs({
							url: online.jsBaseUrl + "calendar.js",
							charset: "utf-8",
							callback: function() {
								online.$c("service.index.CalendarService", {
									parent: a,
									container: [$("#idCalendar")[0], $("#idCalendar1")[0]],
									text: a.msg.ERROR_CALENDAR[0],
									prev: document.getElementById("datePrev"),
									next: document.getElementById("dateNext"),
									dataList: c,
									url: "AjaxBestDeals.aspx?t=HC&cid=0&pid=" + c.fareID + "&dcity=" + c.goCity.value + "&acity=" + c.toCity.value + "&psgnum=" + c.numbers,
									params: c.goDateList,
									params2: c.toDateList,
									endDate: new Date(d[0], 1 * d[1] - 1, d[2]),
									isDouble: !0,
									isSingle: c.single,
									onSubmit: function() {
										$("#DDatePeriod1")[0].value = this.firstDate, $("#ADatePeriod1")[0].value = this.secondDate, $("#HomeCity")[0].value = c.goCity.value, $("#DestCity1")[0].value = c.toCity.value, $("#TicketAgency_List")[0].value = c.goCity.name, $("#Airline")[0].value = c.airline.value, $("#DSeatClass")[0].value = c.classGrade;
										var b = ["European", "American", "Southeast-Asian", "East-Asian", "other-region"];
										document.forms[0].action = "ShowFareFirst.aspx?ctm_campaign=round-trip-benefit&ctm_content=" + b[1 * a.tocity - 1], setTimeout(function() {
											online.maskShow($("#maskshowdiv"), !0, {
												color: "#FFF",
												opacity: 1
											})
										}, 100), document.forms[0].submit()
									},
									onInit: function() {
										$("#calendar_number").parents("div")[0].style.display = parseInt(c.numbers, 10) <= 1 ? "none" : "", $("#xm_flightway")[0].innerHTML = c.single ? a.msg.ERROR_CALENDAR[2] : a.msg.ERROR_CALENDAR[3], $("#calendar_number")[0].innerHTML = c.numbers, $("#calendar_base_price")[0].innerHTML = c.price, $("#prindex_pop_txt")[0].innerHTML = 0 == c.isMany ? c.goCity.name + a.msg.ERROR_CALENDAR[6] + c.toCity.name + c.airline.name + a.msg.ERROR_CALENDAR[7] : c.goCity.name + a.msg.ERROR_CALENDAR[6] + c.toCity.name + a.msg.ERROR_CALENDAR[8]
									},
									getSecondData: function(a, b, c) {
										return c
									}
								}), online.maskShow($("#selectdate"))
							}
						})
					}
				}), $("#box_search").bind("mousedown", function(b) {
					var c = b.target;
					"INPUT" == c.nodeName && c.value == a.msg.SUBMIT && a.searchWait.beforeClick()
				}), this.drpFlightWay.bind("click", this.voyageType.bind(this)), $("#box_search input:not([id='txtAirline']),#box_search select").bind("keydown", this.keydownByCityInput.bind(this), {
					priority: 13
				}), $(".ico_change").bind("click", online.exchangeCity.bind(this, $("#ctl00_MainContentPlaceHolder_txtDCity"), $("#ctl00_MainContentPlaceHolder_dest_city_1"))), $("#ctl00_MainContentPlaceHolder_txtDCity,#ctl00_MainContentPlaceHolder_dest_city_1,#ctl00_MainContentPlaceHolder_txtDDatePeriod1").bind("blur", function() {
					var a = $("#ctl00_MainContentPlaceHolder_txtBeginAddress1"),
						b = $("#ctl00_MainContentPlaceHolder_txtDCity"),
						c = $("#ctl00_MainContentPlaceHolder_txtEndAddress1"),
						d = $("#ctl00_MainContentPlaceHolder_dest_city_1");
					a.value(b[0].value), $("#" + a.attr("mod_address_reference")).value($("#" + b.attr("mod_address_reference")).value()), c.value(d[0].value), $("#" + c.attr("mod_address_reference")).value($("#" + d.attr("mod_address_reference")).value()), $("#ctl00_MainContentPlaceHolder_txtDatePeriod1").value($("#ctl00_MainContentPlaceHolder_txtDDatePeriod1").value())
				})
			}
		}
	}), online.namespaces("service.Index", {}), online.create("service.public.ValidateService", {
		options: {
			submitBtn: online.$get("btnSearchFlight", !0) || $("#btnSearch")[0],
			scheduleBtn: $("#btnFlightSchedule")[0],
			msg: null,
			drpFlightWay: null,
			mult: null,
			single: null,
			flight_multiple: $("#flight_multiple"),
			validateDomesticCity: [],
			callback: function() {}
		},
		methods: {
			initialize: function(a) {
				this.info(), this.extend(this, a);
				var b = $("#NSTime");
				this.errorNumber = 0, this.nowTime = b.length > 0 ? new Date(b.value()) : new Date, this.nextYearTime = new Date(this.nowTime.getFullYear() + 1, this.nowTime.getMonth(), this.nowTime.getDate()), this.submitBtn && (this.submitBtn.disabled = !1, this.submitBtn.style.display = ""), this.scheduleBtn && (this.scheduleBtn.disabled = !1, this.scheduleBtn.style.display = ""), this.errorObj = null, this.index = 0, this.second = 0, this.bindEvent()
			},
			isDomesticCity: function(a) {
				var b = new RegExp("\\|" + a.replace(/\(.+$/g, "") + "\\(");
				return flightintl_dest_cn ? b.test(flightintl_dest_cn) : !0
			},
			getFlightWay: function() {
				var a = this.drpFlightWay;
				return null != a ? "SELECT" == a[0].nodeName ? a.value().toLowerCase() : a.filter(":checked").value().toLowerCase() : "s"
			},
			addDomesticCity: function(a) {
				!this.isDomesticCity(a) && this.validateDomesticCity.push("T")
			},
			dateValue: function(a) {
				return new Date(a.getFullYear(), a.getMonth(), a.getDate())
			},
			validateSingle: function(a) {
				var b = null,
					c = null,
					d = null,
					e = "";
				if (single = this.single, this.errorNumber = 0, this.errorObj = null, c = single.txtDCity, online.isNull(c)) return this.errorNumber = 9, this.errorObj = c, !1;
				if (d = single.dest_city_1, e = d.value, online.isNull(d)) return this.errorNumber = 11, this.errorObj = d, !1;
				if (e == c.value) return this.errorNumber = 12, this.errorObj = d, !1;
				if (b = single.txtDDatePeriod1, online.isNull(b)) return this.errorNumber = 10, this.errorObj = b, !1;
				if (!b.value.isDate()) return this.errorNumber = 4, this.errorObj = b, !1;
				if (e = b.value.toDate(), e < this.dateValue(this.nowTime)) return this.errorNumber = 14, this.errorObj = b, !1;
				if (e > this.dateValue(this.nextYearTime)) return this.errorNumber = 6, this.errorObj = b, !1;
				if (b = single.txtADatePeriod1, "d" == a)
					if (online.isNull(b) && null != this.drpFlightWay) "SELECT" == this.drpFlightWay[0].nodeName ? (this.drpFlightWay.value("S"), this.drpFlightWay[0].selectedIndex = 0) : this.drpFlightWay[0].checked = !0;
					else {
						if (!b.value.isDate()) return this.errorNumber = 4, this.errorObj = b, !1;
						if (e = b.value.toDate(), e < single.txtDDatePeriod1.value.toDate()) return this.errorNumber = 13, this.errorObj = b, !1;
						if (e > this.dateValue(this.nextYearTime)) return this.errorNumber = 6, this.errorObj = b, !1
					}
			},
			validateMore: function() {
				var a = (this.getFlightWay(), null),
					b = null,
					c = null,
					d = "",
					e = this.mult;
				success = !1, prevDateVal = null, len = online.children(this.flight_multiple[0]).length, this.errorNumber = 0, this.errorObj = null, this.validateDomesticCity.length = 0;
				for (var f = 1; len >= f && (a = $("#" + $(e[0] + f).value())[0], b = $("#" + $(e[1] + f).value())[0], c = $("#" + $(e[2] + f).value())[0], this.index = f, d = b.value, !(f > 2 && online.isNull(b))); f++) {
					if (online.isNull(b)) {
						this.errorNumber = 0, this.errorObj = b;
						break
					}
					if (this.addDomesticCity(d), d = c.value, online.isNull(c)) {
						this.errorNumber = 1, this.errorObj = c;
						break
					}
					if (d == b.value) {
						this.errorNumber = 2, this.errorObj = c;
						break
					}
					if (this.addDomesticCity(d), online.isNull(a)) {
						this.errorNumber = 3, this.errorObj = a;
						break
					}
					if (!a.value.isDate()) {
						this.errorNumber = 4, this.errorObj = a;
						break
					}
					if (d = a.value.toDate(), 1 == f && d < this.dateValue(this.nowTime)) {
						this.errorNumber = 5, this.errorObj = a;
						break
					}
					if (prevDateVal && prevDateVal > d) {
						this.errorNumber = 7, this.errorObj = a, this.second = f - 1;
						break
					}
					if (d > this.dateValue(this.nextYearTime)) {
						this.errorNumber = 6, this.errorObj = a;
						break
					}
					prevDateVal = d, this.errorObj = null
				}
				return !this.errorObj && 0 == this.validateDomesticCity.length && (this.errorNumber = 8, this.errorObj = $("#" + $(e[2] + 1).value())[0]), this.errorObj || (success = !0), success
			},
			getValidate: function(a) {
				var b = this.getFlightWay(),
					c = this.msg;
				if (!("m" == b ? this.validateMore() : this.validateSingle(b)) && this.errorObj) return online.registerMod.validateObj.method("show", {
					$obj: $(this.errorObj),
					data: c.ERROR_FLIGHT[this.errorNumber].replace(/{number}/, c.numberList[this.index - 1]).replace(/{this.second}/, c.numberList[this.second - 1]),
					removeErrorClass: !0,
					hideEvent: "blur",
					isFocus: !0
				}), !1;
				if (a) return !0;
				if (this.submitBtn && setTimeout(function() {
					this.submitBtn.disabled = !0
				}.bind(this), 1), this.scheduleBtn && setTimeout(function() {
					this.scheduleBtn.disabled = !0
				}.bind(this), 1), $(window).bind("beforeunload", function() {
					this.submitBtn && (this.submitBtn.disabled = !1), this.scheduleBtn && (this.scheduleBtn.disabled = !0)
				}), this.callback.call(this), "m" == b)
					for (var d = this.flight_multiple.find("li"), e = "", f = 1; f < d.length; f++) $(d[f]).find("input").each(function(a) {
						e = a.attr("mod_save_id"), e && online.registerMod.clearSearchBoxVals(e)
					});
				return online.registerMod.saveSearchBoxVals(), setTimeout(function() {
					this.pageShowWindow()
				}.bind(this), 1), !0
			},
			pageShowWindow: function() {
				var a = null,
					b = "",
					c = this.mult,
					d = this.msg,
					e = this.single,
					f = this.getFlightWay();
				d.MASK = d.MASK ? d.MASK : ["出发的", "多程(含缺口程)", " 航班", "的", " 往返 ", " 单程 ", " 航班 ", "从", "到", "出发日期", "订票数量", "返回日期"], "m" == f ? (a = $("#" + $(c[0] + "1").value()).value(), b = d.MASK[7] + " <strong style='color:#E56700'>" + $("#" + $(c[1] + "1").value()).value() + "</strong> " + d.MASK[0] + " <strong style='color:#E56700'>" + d.MASK[1] + "</strong> " + d.MASK[2]) : (a = e.txtDDatePeriod1.value, b = d.MASK[7] + " <strong style='color:#E56700'>" + e.txtDCity.value + "</strong> " + d.MASK[8] + " <strong style='color:#E56700'>" + e.dest_city_1.value + "</strong> " + d.MASK[3] + " <strong style='color:#E56700'>" + ("d" == f ? d.MASK[4] : d.MASK[5]) + "</strong> " + d.MASK[6]);
				var g = online.$get("txtADatePeriod1", !0) || online.$get("txtADatePeriod1"),
					h = $("#ctl00_MainContentPlaceHolder_drpQuantity").length > 0 ? $("#ctl00_MainContentPlaceHolder_drpQuantity").value() : $("#ctl00_MainContentPlaceHolder_QuickSearchControl_drpQuantity").value();
				$("#alterContent").html(b), $("#DTimeContent").html(d.MASK[9] + ":<strong style='color:#E56700'>" + a + "</strong>"), $("#tictekQuantity").html(d.MASK[10] + ":<strong style='color:#E56700'>" + h + "</strong>"), "d" == f && $("#ATimeContent").html(d.MASK[11] + ":<strong style='color:#E56700'>" + (g ? g.value : "")) + "</strong>", online.maskShow($("#maskshowdiv"), !0, {
					color: "#FFF",
					opacity: 1
				})
			},
			bindEvent: function() {}
		}
	}), online.create("service.public.SearchWaitService", {
		options: {
			WAIT_TIME: 10,
			TIPS_MESSAGER: "",
			WAIT_STATUS: "waitStatus"
		},
		methods: {
			initialize: function(a) {
				this.info(), this.extend(this, a), this.timerStatus = null, this.waitStatus = $.cookie.get(this.WAIT_STATUS)
			},
			beforeClick: function() {
				if (null != this.waitStatus) {
					var a = 1 * this.waitStatus,
						b = (new Date).getTime(),
						c = (b - a) / 1e3;
					if (c < this.WAIT_TIME) return alert(this.TIPS_MESSAGER), !1
				}
			},
			afterClick: function() {
				$.cookie.set(this.WAIT_STATUS, null, (new Date).getTime())
			}
		}
	}), online.create("util.Multipass", {
		options: {
			template: '			<div class="s_item_cont" online_multipass_index="${index-1}">				<div class="s_item_voyage online_number">${index}</div>				<div class="s_item online_label">					${i18n.startCity}					<input name="txtBeginAddress${index}" type="text" id="fl_txtBeginAddress${index}" mod_change_id="fl_txtEndAddress${index-1}" {{if index ==1}} mod_save_id="flightintl_startcity_single" mod_save_value="true"{{/if}} mod_address_source="flightintl_start" class="input_text" mod_address_focusnext="true" mod_notice_tip="中文/英文/拼音" mod_address_reference="fl_txtBeginCityCode${index}" mod="address|notice" mod_address_tpl="address" autocomplete="off" />				</div>				<div class="s_item2 online_label">					${i18n.startDate}					<input name="txtDatePeriod${index}" type="text" id="fl_txtDatePeriod${index}" class="input_text" mod="calendar|notice"  {{if index ==1}}mod_save_value="true" mod_save_id="flightintl_startdate_single"{{/if}} mod_notice_tip="yyyy-mm-dd" mod_calendar_reference="fl_txtDatePeriod${index-1}" mod_calendar_focusnext="fl_txtDatePeriod${index+1}~fl_txtEndAddress${index}" autocomplete="off" />				</div>				<div class="s_item2 online_label">					${i18n.endCity}					<input name="txtEndAddress${index}" mod_address_focusnext="true" type="text" id="fl_txtEndAddress${index}" class="input_text" {{if index ==1}} mod_save_value="true" mod_save_id="flightintl_arrivalcity_single"{{/if}} mod_notice_tip="中文/英文/拼音" mod_address_source="flightintl_dest" mod_address_reference="fl_txtEndCityCode${index}" mod="address|notice" mod_address_tpl="address" mod_next_value="fl_txtBeginAddress${index+1}" autocomplete="off" />				</div>				<a class="s_item_del del_line" href="javascript:;" style="{{if index<=2}}display:none{{/if}}"></a>				<input name="txtBeginCityCode${index}" type="hidden" id="fl_txtBeginCityCode${index}" value="">				<input name="txtEndCityCode${index}" type="hidden" id="fl_txtEndCityCode${index}" value="">			</div>		',
			i18n: {
				big5: {
					startCity: "出發城市",
					endCity: "到達城市",
					startDate: "出發日期"
				},
				gb2312: {
					startCity: "出发城市",
					endCity: "到达城市",
					startDate: "出发日期"
				}
			},
			target: $("#fl_flight_multiple"),
			container: $("#fl_multiple_div"),
			addTarget: $("#fl_add_new_line"),
			vals: online.registerMod ? online.registerMod.searchBoxVals : "",
			max: 6,
			min: 3,
			defaultValue: {},
			removeCallback: function() {},
			addCallback: function() {}
		},
		methods: {
			initialize: function(a) {
				if (this.info(), this.extend(this, a), this.target && !(this.target.length <= 0)) {
					this.i18n = this.i18n[online.charset], this.currentIndex = 0, online.extend(this.vals, this.defaultValue);
					var b = online.children(this.target[0]).length;
					if (this.index = b, b < this.min) {
						for (var c = this.min - b, d = "", e = 0; c > e; e++) d += this.render();
						online.insertHtml("beforeend", this.target[0], d), online.registerMod.registerAll(this.target.find("[mod]"))
					}
					this.index >= this.max && (this.addTarget[0].style.display = "none"), this.vals.moreflightMin = this.index, this.bindEvent()
				}
			},
			opacity: {
				set: function(a, b) {
					var c = a.style;
					$.browser.isIE ? (c.filter = (c.filter || "").replace(/alpha\([^\)]*\)/gi, "") + (1 == b ? "" : "alpha(opacity=" + 100 * b + ")"), c.zoom = 1) : c.opacity = "number" == $.type(b) ? b : 0
				},
				get: function(a) {
					var b = a.currentStyle ? a.currentStyle : window.getComputedStyle(a, null),
						c = 1;
					if ($.browser.isIE) {
						var d = b.filter;
						c = d && d.indexOf("opacity=") >= 0 ? parseFloat(d.match(/opacity=([^)]*)/)[1]) / 100 : 1
					} else c = b.opacity;
					return c *= 1
				}
			},
			render: function() {
				var a = {
					index: ++this.index,
					i18n: this.i18n
				};
				return this.index >= this.max && (this.addTarget[0].style.display = "none"), $.tmpl.render(this.template, a)
			},
			add: function() {
				if (!(this.index >= this.max)) {
					online.insertHtml("beforeend", this.target[0], this.render());
					var a = online.last(this.target[0]),
						b = this;
					if (a) {
						var c = 0;
						a.style.background = "#E8F4FF", a.style.display = "", this.opacity.set(a, c),
						function() {
							c += .1, 1 > c ? (b.opacity.set(a, c), setTimeout(arguments.callee, 20)) : (a.style.background = "none", online.registerMod.registerAll($(a).find("[mod]")), b.vals.moreflightMin = b.index)
						}(), b.addCallback.call(this, $(a))
					}
				}
			},
			remove: function(a) {
				var b = online.parent(a),
					c = this;
				b.style.background = "#E8F4FF";
				var d = 1;
				this.currentIndex = 0 | b.getAttribute("online_multipass_index"), this.removeCallback.call(this, $(b)),
				function() {
					if (d -= .1, d > .1) c.opacity.set(b, d), setTimeout(arguments.callee, 10);
					else {
						var a = "";
						$(b).find("input").each(function(b) {
							a = b.attr("mod_save_id"), a && online.registerMod.clearSearchBoxVals(a)
						}), $(b).remove(), c.update()
					}
				}()
			},
			update: function() {
				--this.index, this.vals.moreflightMin = this.index, this.index <= this.max && this.addTarget.show();
				for (var a = online.children(this.target[0]), b = "", c = "", d = this, e = "", f = this.currentIndex, g = a.length; g > f; f++) $(a[f]).find(".line_num em:eq(0)").html(f + 1), $(a[f]).find(".online_number:eq(0)").html(f + 1), $(a[f]).attr("online_multipass_index", f), $(a[f]).find("input").each(function(a) {
					a[0].id = a[0].id.replace(/\d+$/, f + 1), a[0].name = a[0].name.replace(/\d+$/, f + 1), b = a.attr("mod_address_reference"), b && a.attr("mod_address_reference", b.replace(/\d+$/, f + 1)), b = a.attr("mod_calendar_reference"), b && a.attr("mod_calendar_reference", b.replace(/\d+$/, f)), a.attr("mod") && null != a.attr("mod").match("calendar") && (b && (c = $("#" + a.attr("mod_calendar_reference")).value().trim(), c.isDate() && a.data("minDate", c)), b = a.attr("mod_calendar_focusnext"), b && (b = b.split("~"), b[0] = b[0].replace(/\d+$/, f + 2), b.length > 1 && "1" != b[1] && (b[1] = b[1].replace(/\d+$/, f + 1)), a.attr("mod_calendar_focusnext", b.join("~")))), b = a.attr("mod_next_value"), b && a.attr("mod_next_value", b.replace(/\d+$/, f + 2)), b = a.attr("mod_change_id"), b && a.attr("mod_change_id", b.replace(/\d+$/, f)), b = a.attr("mod_save_id"), b && (e = d.vals[b], online.registerMod.clearSearchBoxVals(b), b = b.replace(/\d+$/, f + 1), d.vals[b] = e, a.attr("mod_save_id", b))
				})
			},
			bindEvent: function() {
				var a = this;
				this.target.bind("mousedown", function(b) {
					var c = b.target;
					$(c).hasClass("del_line") && a.remove(c)
				}), this.addTarget.bind("click", a.add.bind(this))
			}
		}
	}), online.config.airline = function(a, b) {
		var c = {
			template: {
				suggestionInit: function(a) {
					var c = a.find("a[data]");
					c.bind("mouseover", function() {
						$(this).addClass("hover")
					}).bind("mouseout", function() {
						$(this).removeClass("hover")
					}), $(b.modElement).bind("blur", function() {
						a.hide()
					}).bind("focus", function() {
						a.show()
					}).bind("keyup", function(a) {
						var b = a.target,
							c = online.$get("btnSearchFlight"),
							d = isNaN(a.keyCode) ? a.charCode : a.keyCode;
						13 == d && "txtAirline" == b.id && c.focus()
					})
				},
				suggestionIpad: '<a href="javascript:void(0)" class="ico_key" id="mini_c_address_keyboard">Keyboard</a><a href="javascript:void(0)" class="address_close" id="mini_c_address_close">close</a>',
				suggestion: '<div class="c_address_select"><div class="c_address_wrap">{ipad}<div class="c_address_hd">输入中文|代码搜索或↑↓选择.</div><div style="" class="c_address_list">{{enum(key,arr) data}}{{each arr}}<a href="javascript:;" title="${display}" data="${data}"><span>${rightDisplay}</span>${display}</a>{{/each}}{{/enum}}</div></div></div>',
				suggestionStyle: '				.c_address_hd { height: 24px; border-color: #2C7ECF; border-style: solid; border-width: 1px 1px 0; background-color: #67A1E2; color: #fff; line-height: 24px; text-align:center }				.c_address_bd { border-color: #999999; border-style: solid; border-width: 0 1px 1px; overflow: hidden; padding:10px; }				.c_address_select { width:222px; height:355px; font-family: Arial, Simsun; font-size: 12px; }				.c_address_wrap { width: 220px; height:349px; min-height: 305px; margin: 0; padding: 0 0 4px; border: 1px solid #969696; background:#fff; text-align: left; }				.c_address_hd { margin:-1px; }				.c_address_list { margin: 0; padding: 0; height:300px; }				.c_address_list span { float: right; font: 10px/22px verdana; margin: 0; overflow: hidden; padding: 0; text-align: right; white-space: nowrap; width: 110px; }				.c_address_list a { border-bottom: 1px solid #FFFFFF; border-top: 1px solid #FFFFFF; color: #0055AA; cursor: pointer; display: block; height: 22px; line-height: 22px; min-height: 22px; overflow: hidden; padding: 1px 9px 0; text-align: left; text-decoration: none; }				.c_address_list a.hover,.c_address_list a:hover { background: none repeat scroll 0 0 #E8F4FF; border-bottom: 1px solid #7F9DB9; border-top: 1px solid #7F9DB9; }				.address_selected { background: none repeat scroll 0 0 #FFE6A6; color: #FFFFFF; height: 22px; }				.c_address_pagebreak { line-height: 25px; margin: 0; padding: 0; text-align: center; }				.c_address_pagebreak a { color: #0055AA; display: inline-block; font-family: Arial, Simsun, sans-serif; font-size: 14px; margin: 0; padding: 0 4px; text-align: center; text-decoration: underline; width: 15px; }				a.address_current { color: #000; text-decoration: none; }				.c_address_select .ico_key, .c_address_select .ico_unkey{position: absolute;top: 1px;left: 1px;width: 34px;height: 24px;overflow: hidden;line-height: 999em;font-size: 0;content: "";background: url(http://pic.c-ctrip.com/ctripOnPad/ico_key.png) no-repeat 0 0;-webkit-transform: scale(.7);}				.c_address_select .address_close {position: absolute;top: 3px;right: 4px;width: 18px;height: 19px;overflow: hidden;line-height: 999em;font-size: 0;content: "";text-indent: 99em;background: url(http://pic.c-ctrip.com/ctripOnPad/pad_address_icon.png) no-repeat -32px 0;-webkit-transform: scale(0.5);}				.c_address_select .ico_unkey {background: url(http://pic.c-ctrip.com/ctripOnPad/ico_unkey.png) no-repeat 0 0;}			'
			}
		};
		return online.extend(c.template, {
			suggestionInitIpad: c.template.suggestionInit,
			suggestionIpad: c.template.suggestion.replace("{ipad}", c.template.suggestionIpad),
			suggestionStyleIpad: c.template.suggestionStyle,
			suggestion: c.template.suggestion.replace("{ipad}", "")
		}), c
	}, online.config.address = function(a) {
		var b = {
			message: {
				filterResult: "${val}，按字符顺序排序",
				noFilterResult: " 对不起，无匹配，请重新输入。 "
			},
			template: {
				filterPageSize: 10,
				suggestionStyle: "				.c_address_box { background-color: #fff; font-size: 12px; width: 435px !important; }				.c_address_box a { text-decoration: none; }				.c_address_hd { height: 24px; border-color: #2C7ECF; border-style: solid; border-width: 1px 1px 0; background-color: #67A1E2; color:#CEE3FC; line-height: 24px; padding-left: 10px; }				.c_address_hd strong{color:#fff;}				.c_address_bd { border-color: #999999; border-style: solid; border-width: 0 1px 1px; overflow: hidden; padding:10px; }				.c_address_ol { margin:0; padding:0 0 20px; border-bottom: 1px solid #5DA9E2; }				.c_address_ol li { color: #005DAA; cursor: pointer; float: left; height: 20px; line-height: 20px; list-style-type: none; text-align: center; }				.c_address_ol li span { padding:0 8px; white-space:nowrap; display:block; }				.c_address_ol li .hot_selected { display:block; padding:0 7px; background-color: #FFFFFF; border-color: #5DA9E2; border-style: solid; border-width: 1px 1px 0; color: #000000; font-weight: bold; }				.c_address_ul { width: 100%; margin:0; padding: 4px 0 0; }				.c_address_ul li { float: left; height: 24px; overflow: hidden; width: 103px; }				.c_address_ul li a { display: block; height: 22px;  border: 1px solid #FFFFFF; color: #1148A8; line-height: 22px; padding-left: 5px; }				.c_address_ul li a:hover { background-color: #E8F4FF; border: 1px solid #ACCCEF; text-decoration: none; }			",
				suggestionStyleIpad: '				.c_address_box {position:relative;width:435px !important;background-color:#FFFFFF;font-size:12px;}				.c_address_box a {text-decoration:none;}				.c_address_hd {padding-left:10px;padding-right:24px;height:24px;text-indent:32px;text-align:center;border-color:#2C7ECF;border-style:solid;border-width:1px 1px 0;background-color:#67A1E2;color:#CEE3FC;line-height:24px;}				.c_address_hd strong {color:#FFFFFF;}				.c_address_bd {overflow:hidden;padding:10px;border-color:#999999;border-style:solid;border-width:0 1px 1px;}				.c_address_ol {margin:0;padding:0 0 20px;border-bottom:1px solid #5DA9E2;}				.c_address_ol li {float:left;height:20px;color:#005DAA;list-style-type:none;text-align:center;line-height:20px;cursor:pointer;}				.c_address_ol li span {display:block;padding:0 8px;white-space:nowrap;}				.c_address_ol li .hot_selected {display:block;padding:0 7px;border-color:#5DA9E2;border-style:solid;border-width:1px 1px 0;background-color:#FFFFFF;color:#000000;font-weight:bold;}				.c_address_ul {margin:0;padding:4px 0 0;width:100%;}				.c_address_ul li {float:left;overflow:hidden;width:103px;height:24px;}				.c_address_ul li a {display:block;padding-left:5px;height:22px;border:1px solid #FFFFFF;color:#1148A8;line-height:22px;}				.c_address_ul li a:hover {border:1px solid #ACCCEF;background-color:#E8F4FF;text-decoration:none;}				.c_address_box .ico_key,				.c_address_box .ico_unkey {position:absolute;top:1px;left:1px;width:34px;height:24px;overflow:hidden;line-height:999em;font-size:0;content:"";background:url(http://pic.c-ctrip.com/ctripOnPad/ico_key.png) no-repeat 0 0;-webkit-transform:scale(.7);}				.c_address_box .ico_unkey {background:url(http://pic.c-ctrip.com/ctripOnPad/ico_unkey.png) no-repeat 0 0;}				.c_address_box .address_close  {position:absolute;top:3px;right:4px;width:18px;height:19px;overflow:hidden;line-height:999em;font-size:0;content:"";text-indent:99em;background:url(http://pic.c-ctrip.com/ctripOnPad/pad_address_icon.png) no-repeat -32px 0;-webkit-transform:scale(0.5);}			',
				filter: '				<div class="c_address_select">					<div class="c_address_wrap">						<div class="{{if !hasResult}}c_address_hd_error{{else}}c_address_hd{{/if}}">{{if hasResult}}{{tmpl message.filterResult}}{{else}}{{tmpl message.noFilterResult}}{{/if}}</div>						{{if hasResult}}							<div class="c_address_list">								{{each (i,item) list}}									{{if cQuery.type(item)=="string"}}										<label>${item}</label>									{{else}}										<a href="javascript:void(0);" data="${data}" style="display: block;">{{tmpl data.split("|")[3] }}<span>${left}</span></a>									{{/if}}								{{/each}}							</div>							{{if page.max>0}}								<div class="c_address_pagebreak">									{{if page.current>0}}										<a href="javascript:void(0);" page="${page.current-1}">&lt;-</a>									{{/if}}									{{if page.current<2}}										{{loop(index) Math.min(5,page.max+1)}}											<a href="javascript:void(0);"{{if page.current==index}} class="address_current"{{/if}} page="${index}">${index+1}</a>										{{/loop}}									{{else page.current>page.max-2}}										{{loop(index) Math.max(0,page.max-4),page.max+1}}											<a href="javascript:void(0);"{{if page.current==index}} class="address_current"{{/if}} page="${index}">${index+1}</a>										{{/loop}}									{{else}}										{{loop(index) Math.max(0,page.current-2),Math.min(page.current+3,page.max+1)}}											<a href="javascript:void(0);"{{if page.current==index}} class="address_current"{{/if}} page="${index}">${index+1}</a>										{{/loop}}									{{/if}}									{{if page.current<page.max}}										<a href="javascript:void(0);" page="${page.current+1}">-&gt;</a>									{{/if}}								</div>							{{/if}}						{{/if}}					</div>				</div>			',
				filterStyle: "				.c_address_hd,.c_address_hd_error{ height: 24px; border-color: #2C7ECF; border-style: solid; border-width: 1px 1px 0; background-color: #67A1E2; color: #fff; line-height: 24px; padding-left: 10px; }				.c_address_bd { border-color: #999999; border-style: solid; border-width: 0 1px 1px; overflow: hidden; padding:10px; }				.c_address_select { width:302px; font-family: Verdana, Arial; font-size: 12px; }				.c_address_wrap { width:300px; margin:0; padding:0 0 4px; border:1px solid #969696; background:#fff; text-align:left; }				.c_address_hd { margin:-1px; }				.c_address_hd_error { margin:-1px -1px -4px; }				.c_address_list { margin: 0; padding: 0; _height:370px; }				.c_address_list label { display: block; height:30px; padding:7px 9px 0; text-align: center; }				.c_address_list span { display:block; font: 10px/12px verdana; margin: 0; overflow: hidden; padding: 0; white-space: nowrap; color:#999; -webkit-text-size-adjust:none; }				.c_address_list a { border-bottom: 1px solid #FFFFFF; border-top: 1px solid #FFFFFF; color: #0055AA; cursor: pointer; display: block; height: 30px; line-height: 14px; min-height: 22px; overflow: hidden; padding:5px 9px 0; text-align: left; text-decoration: none; }				.c_address_list a.hover { background: none repeat scroll 0 0 #E8F4FF; border-bottom: 1px solid #7F9DB9; border-top: 1px solid #7F9DB9; }				.c_address_list b { color:#03459d; }				.address_selected { background: none repeat scroll 0 0 #FFE6A6; color: #FFFFFF; height: 22px; }				.c_address_pagebreak { line-height: 25px; margin: 0; padding: 0; text-align: center; }				.c_address_pagebreak a { color: #0055AA; display: inline-block; font-family: Arial, Simsun, sans-serif; font-size: 14px; margin: 0; padding: 0 4px; text-align: center; text-decoration: underline; width: 15px; }				a.address_current { color: #000; text-decoration: none; }			"
			},
			jsonpFilter: ("undefined" != typeof jsonpAddressUrl ? jsonpAddressUrl : online.siteName + "international/tools/GetCities.ashx") + "?s=${key}&a=" + ("flightintl_start" == a[0].getAttribute("mod_address_source") ? "0" : "1") + "&t=" + ("big5" == $.config("charset") ? "1" : "0"),
			delay: 50
		};
		return online.extend(b.template, {
			filterIpad: b.template.filter,
			filterStyleIpad: b.template.filterStyle
		}), b
	}, online.create("util.RegisterMod", {
		options: {
			version: {
				address: "1.0",
				notice: "1.1",
				validate: "1.1",
				jmpInfo: "1.0",
				jmp: "1.0",
				calendar: "6.0",
				mask: "1.0",
				adFrame: "1.0",
				allyes: "1.0",
				tab: "1.2"
			},
			elements: $("[mod]"),
			charset: $.config("charset"),
			inits: {},
			resource: ["http://webresource.c-ctrip.com/code/cquery/resource/address/flightintl/"],
			jmpInfoTpl: {
				jmp_title: '<div class="jmp_hd"><h3 id="para1">${txt0}</h3></div><div id="para2" class="jmp_bd">${txt1}</div>',
				"#transit": '<div class="jmp_hd"><h3 id="txt0">${txt0}</h3></div><div class="jmp_bd"><div><span id="txt1" class="pubFlights_${txt3} airline">&nbsp;${txt1}</span> </div><div class="prindex_turn">转<span></span></div><div><span id="txt2" class="pubFlights_${txt4} airline">&nbsp;${txt2}</span></div></div>'
			}
		},
		methods: {
			initialize: function(a) {
				this.info(), this.extend(this, a);
				for (var b in this.version) this.inits[b] = {};
				this.saveStorage = "flightintl_searchBoxVals_" + this.charset;
				var c = $.cookie.get(this.saveStorage) || !1;
				this.searchBoxVals = c ? $.parseJSON(c) : $.storage.get(this.saveStorage) || {};
				var c = $.cookie.get(this.saveStorage) || !1;
				this.modElement = null, this.isRegisterJmp = !1
			},
			clearNotice: function(a) {
				!online.isNull(a) && online.removeClass(a, "inputSel")
			},
			getFirstCityNameByIp: function(a) {
				if (a.length <= 0 || "" != a.value().trim()) return !1;
				var b = this.searchBoxVals.flightintl_startcity_single || arguments[1],
					c = this;
				b && "" != b && "undefined" != typeof b || $.loader.jsonp(online.siteName + "international/tools/GetUserPosition.ashx?t=" + ("big5" == online.charset ? "1" : "0"), {
					charset: online.charset,
					onload: function(b) {
						if ("" != b && -1 != b.indexOf("|") && b.length < 150) {
							var d = a.attr("mod_save_id");
							d && (c.searchBoxVals[d] = b), b = b.split("|"), a.value(b[0]), $("#" + a.attr("mod_address_reference")).value(b[1]), c.clearNotice(a[0])
						}
					}.bind(this)
				})
			},
			saveSearchBoxVals: function() {
				$.cookie.set(this.saveStorage, null, $.stringifyJSON(this.searchBoxVals), {
					domain: online.domain,
					path: "/",
					expires: 365
				}), $.storage.set(this.saveStorage, this.searchBoxVals)
			},
			clearSearchBoxVals: function(a) {
				a && delete this.searchBoxVals[a]
			},
			getMod: function(a, b) {
				return $(a).getMod(b, this.version[b])
			},
			register: function(a) {
				$.mod.multiLoad({
					tab: this.version.tab,
					address: this.version.address,
					calendar: this.version.calendar,
					notice: this.version.notice,
					validate: this.version.validate,
					allyes: this.version.allyes,
					adFrame: this.version.adFrame,
					jmp: this.version.jmpInfo
				}, function() {
					this.validateObj = this.getValidate(), a && a.apply(this, arguments), $.mod.load("validate", this.version.validate), this.registerAll()
				}.bind(this))
			},
			_switchAddress: function() {
				try {
					return $("#hdn_enableCitySelectAjaxCall").length > 0 && $("#hdn_enableCitySelectAjaxCall").value() + "" == "1" ? !0 : !1
				} catch (a) {
					return !1
				}
			},
			register_address: function(a) {
				var b = a[0].getAttribute("focus_loader"),
					c = this,
					d = this.version.address,
					e = this._switchAddress(),
					f = "";
				this.modElement = a;
				var g = function(a) {
					var b = a[0].getAttribute("mod_address_source"),
						g = a[0].getAttribute("id") || a.attr("name"),
						h = $("#" + a[0].getAttribute("mod_address_reference")),
						i = a.attr("mod_save_id"),
						j = a[0].getAttribute("mod_address_focusnext"),
						k = a.attr("mod_save_value");
					k = k && "true" == k.toLowerCase() ? !0 : !1;
					var l = a[0].getAttribute("mod_address_tpl") ? online.config[f = a[0].getAttribute("mod_address_tpl")](a, this) : {};
					"address" == f && e && (b += "_new");
					var m = {
						name: g,
						jsonpSource: "http://webresource.c-ctrip.com/code/cquery/resource/address/flightintl/" + b + "_" + online.charset + ".js",
						isFocusNext: !1,
						_isFocusNext: j && "true" == j ? !0 : "false" == j ? !1 : $("#" + j),
						isAutoCorrect: !0,
						relate: {
							2: h
						},
						offset: a[0].getAttribute("mod_address_position") ? 1 * a[0].getAttribute("mod_address_position") : 5,
						sort: ["^0$", "^1$", "^3$", "^0", "^1", "^3", "0", "1", "3", "^4+$"],
						message: {
							sort: ["", "", "", "", "", "", "", "", "", '"${val}" 国家名，相关城市']
						}
					}, n = function(a) {
							var b = a.attr("mod_next_value") ? $("#" + a.attr("mod_next_value")) : [],
								c = c = a.value() + "|" + $("#" + a.attr("mod_address_reference")).value();
							a.attr("mod_change_value", c), b && b.length > 0 && !online.isNull(a[0]) && (online.isNull(b[0]) || null == b.value().match(/\([a-zA-Z]+\)/)) && b.attr("mod_change_id", a.attr("id"))
						};
					if ("address" == f && e ? $.extend(m, l) : "address" != f && $.extend(m, l), "true" === $("#hdn_IsIncludedNoBookingFlights").value().toLowerCase() && (delete m.jsonpSource, m.source = "gb2312" == online.charset ? {
						data: "@China|中国大陆|CN@",
						suggestion: {
							"": [{
								display: "中国大陆",
								data: "China|中国大陆|CN",
								rightDisplay: "China"
							}]
						}
					} : {
						data: "@China|中國大陸|CN@",
						suggestion: {
							"": [{
								display: "中國大陸",
								data: "China|中國大陸|CN",
								rightDisplay: "China"
							}]
						}
					}), $.mod.load("address", d, function() {
						c.inits.address[g] = a.regMod("address", d, m), c.inits.address[g].method("bind", "change", function(a, b) {
							var d = b.items;
							i && d && (c.searchBoxVals[i] = d[1] + "|" + d[2] + "|" + d[0]), n($(this)), setTimeout(function() {
								this.blur()
							}.bind(this))
						}), a.bind("focus", function() {
							var a = this.getAttribute("mod_change_id"),
								b = $("#" + a).attr("mod_change_value");
							if (online.isNull(this) && b) {
								b = b.split("|"), $(this).value(b[0]);
								var c = $("#" + $(this).attr("mod_address_reference"));
								c.length > 0 && c.value(b[1])
							}
						}).bind("blur", function() {
							var a = null,
								b = m._isFocusNext;
							if (b || $.isCDom(b)) {
								if ($.isCDom(b)) a = b[0];
								else switch ($.type(b)) {
									case "string":
										a = $(b)[0];
										break;
									case "object":
										"focus" in b && (a = b);
										break;
									case "boolean":
										var c = this.form;
										if (c)
											for (var d = c.elements, e = 0, f = 0, g = d.length - 1; g > f; f++) {
												if (e) {
													var h = $(d[f]);
													if ((d[f].offsetWidth || d[f].offsetHeight) && "none" !== h.css("display") && "hidden" !== h.css("visibility")) {
														a = d[f];
														break
													}
												}
												d[f] == this && (e = 1)
											}
								}
								a && online.isNull(a) && !online.isNull(this) ? setTimeout(function() {
									try {
										a.focus()
									} catch (b) {}
								}) : this.blur()
							}
						})
					}), k && i) {
						var o = c.searchBoxVals[i];
						if (o) {
							var p = o.split("|");
							a.value(p[0]), h.value(p[1])
						}
					}
					c.clearNotice(a[0]), n(a), a[0].setAttribute("init_mod", "T")
				}.bind(this);
				b ? a.bind("focus", g.bind(this, a)) : g(a)
			},
			getValidate: function() {
				return this.validateObj = $(document).regMod("validate", this.version.validate)
			},
			validate: function(a, b) {
				this.validateObj.method("show", {
					$obj: $(a),
					data: b,
					removeErrorClass: !0,
					hideEvent: "blur",
					isFocus: !0
				})
			},
			registerAll: function(a) {
				for (var b = a ? a : this.elements, c = [], d = 0, e = b.length; e > d; d++) {
					var f = b[d],
						g = f.getAttribute("mod");
					if (g)
						if (c = -1 != g.indexOf("|") ? g.split("|") : g, "string" == typeof c && this["register_" + c]) this["register_" + c]($(f));
						else
							for (var h = 0, i = c.length; i > h; h++) this["register_" + c[h]] && this["register_" + c[h]]($(f))
				}
				this.isRegisterJmp || (this.docRegisterJmpInfo(), this.isRegisterJmp = !0)
			},
			docRegisterJmpInfo: function() {
				var a = this.version.jmp;
				$.mod.load("jmp", a, function() {
					$(document).regMod("jmp", a, {})
				})
			},
			register_linklist2: function(a) {
				var b = a[0].getAttribute("mod_linklist_id");
				if ("undefined" != typeof window.c_linklist2 && b && (b = window.c_linklist2[b]) && b.constructor === Array) {
					for (var c = [], d = '<a href="{$link}" rel="nofollow" title="{$text}" target="{$target}">{$text}</a>', e = 1; 6 >= e; e++) {
						var f = b[e].split("|", 2);
						b[e] = online.replaceWith(d, {
							text: f[0],
							link: f[1],
							target: b[e].target || "_blank"
						}), c.push(b[e])
					}
					a.html(c.join(""))
				}
			},
			register_allyes: function(a) {
				var b = this.version.allyes;
				$.mod.load("allyes", b, function() {
					$(a).regMod("allyes", b, {
						mod_allyes_user: $(a)[0].getAttribute("mod_allyes_user")
					}), a[0].setAttribute("init_mod", "T")
				})
			},
			register_adFrame: function(a) {
				var b = this.version.adFrame;
				$.mod.load("adFrame", b, function() {
					a.regMod("adFrame", b, {
						mod_adframe_style: a[0].getAttribute("mod_adframe_style"),
						mod_adframe_src: a[0].getAttribute("mod_adframe_src")
					}), a[0].setAttribute("init_mod", "T")
				})
			},
			register_notice: function(a) {
				var b = a[0].getAttribute("id") || a.attr("name") || $.uid(),
					c = a[0].getAttribute("mod_notice_tip") || "",
					d = this.version.notice,
					e = this;
				$.mod.load("notice", d, function() {
					e.inits[b + "_notice"] = e.inits.notice[b] = a.regMod("notice", d, {
						name: b,
						tips: c,
						selClass: "inputSel"
					}).method("checkValue"), e.clearNotice(a[0]), a[0].setAttribute("init_mod", "T")
				})
			},
			registerJmpInfo: function(a) {
				var b = this;
				$(a).find("[mod='jmpInfo']").each(function(a) {
					a[0].getAttribute("init_mod") && "T" == a[0].getAttribute("init_mod") || b.register_jmpInfo(a, !0)
				})
			},
			getTableTips: function(a) {
				var b = {};
				return a = this.getAspByJmpInfo(a), b.txt0 = null != a ? a : {}, b
			},
			register_Select: function(element) {
				var params = eval("(" + element[0].getAttribute("mod_Select") + ")");
				params.options.target = element[0].id, online.$c("util.Select", params)
			},
			register_SortButton: function(element) {
				var params = eval("(" + element[0].getAttribute("mod_SortButton") + ")");
				params.options.target = element[0].id, online.$c("util.SortButton", params)
			},
			getAspByJmpInfo: function(a) {
				if (a = "string" != typeof a ? a.getAttribute("mod_jmpinfo_page") : a, a = -1 != a.indexOf("?") ? a.match(/=(\w+)/)[1] : "", "" != a && $$.module.jmpInfo.array.CraftType) {
					var b = {}, c = $$.module.jmpInfo.array.CraftType.match(new RegExp("@(" + a + "\\|[^@]*\\|[^@]*\\|\\d*\\|\\d*)@", "i"));
					if (!c || null == c) return !1;
					c = c[1].split("|");
					for (var d = 0, e = c.length; e > d; d++) b["txt" + d] = c[d];
					return b
				}
				return null
			},
			register_jmpInfo: function(a) {
				var b = this.version.jmpInfo,
					c = this;
				"jmp_table" == a[0].getAttribute("mod_jmpinfo_type") && arguments.length <= 1 || $.mod.load("jmp", b, function() {
					var d = {}, e = -1 != a[0].getAttribute("mod_jmpinfo_content").indexOf("|") ? a[0].getAttribute("mod_jmpinfo_content").split("|") : a[0].getAttribute("mod_jmpinfo_content"),
						f = {};
					if (e && "object" == typeof e)
						for (var g = 0, h = e.length; h > g; g++) f["txt" + g] = e[g];
					else f.txt0 = e || ""; if (a[0].getAttribute("mod_jmpinfo_type")) {
						var i = a[0].getAttribute("mod_jmpinfo_type");
						d = {
							type: i,
							template: "#" + i,
							classNames: {
								boxType: i
							}
						}
					} else d = {
						template: "$jmp_title",
						type: "jmp_title",
						classNames: {
							boxType: "jmp_title"
						},
						templs: {
							tipTempl: ['<div id=${id} class=${tip} group=${group} style="visibility:hidden;display:block;z-index:99;margin:0;left:-9999px;top:-9999px;overflow:hidden;position:absolute;width:320px;"><div id="tuna_jmpinfo">', '<div class="${box} ${boxType} ${boxArrow}">', '<b class="${arrow}"></b>', '<div class="${loading}">${loadingImg}</div>', "<div class=${content}></div>", "</div>", "</div>", "</div>"].join(""),
							jmp_title: c.jmpInfoTpl[a[0].getAttribute("mod_jmpinfo_page")]
						}
					}; if (a[0].getAttribute("mod_jmpinfo_ajax")) d.dataUrl = "", d.css = {
						maxWidth: "300"
					}, d.url = online.ajaxUrl[a[0].getAttribute("mod_jmpinfo_ajax") + "AjaxUrl"], d.url += -1 != d.url.indexOf("?") ? "&" + a[0].getAttribute("param") : "?" + a[0].getAttribute("param");
					else {
						var j = c.getAspByJmpInfo(a[0]);
						j && null != j && (f.txt0 = j, d.css = {
							maxWidth: "490"
						}), d.content = f
					}
					d.boundaryShow = !1, d.position = a[0].getAttribute("mod_jmpinfo_position") || "leftMiddle-leftTop", a.regMod("jmp", b, {
						options: d
					}), a[0].setAttribute("init_mod", "T")
				})
			},
			register_calendar: function(a, b) {
				var c = this.version.calendar,
					d = this,
					e = a.attr("mod_save_value"),
					f = a.attr("mod_save_id"),
					g = a[0].id || "";
				e = e && "true" == e.toLowerCase() ? !0 : !1, $.mod.load("calendar", c, function() {
					var h = {
						autoShow: !1,
						showWeek: !0,
						maxDate: function() {
							var a = (new Date).addYears(1);
							return a.getFullYear() + "-" + (a.getMonth() + 1) + "-" + a.getDate()
						}()
					}, i = {
							onBeforeShow: function() {},
							onChange: function(a, b) {
								f && (d.searchBoxVals[f] = b);
								var c = $(a).attr("mod_calendar_focusnext"),
									e = null,
									g = 0;
								return c && "undefined" != typeof c ? (-1 != c.indexOf("~") ? (c = c.split("~"), g = c.length, e = document.getElementById(c[0])) : c && (e = document.getElementById(c)), e && $(e).data("minDate", b), void(g > 1 && (e = "1" != c[1] ? document.getElementById(c[1]) : e, e.offsetHeight > 0 && online.isNull(e) ? e.focus() : e && online.isNull(e) ? g > 1 && $(e).parents("li").length > 0 && "none" != $($(e).parents("li")[0]).css("display") && e.focus() : setTimeout(function() {
									$(a)[0].blur()
								})))) : void setTimeout(function() {
									$(a)[0].blur()
								})
							}
						};
					if (a[0].getAttribute("mod_calendar_reference") && (h.reference = "#" + a[0].getAttribute("mod_calendar_reference")), online.extend(h, b || {}), online.extend(i, b ? b.listeners : {}), d.inits.calendar[g] = a.regMod("calendar", c, {
						options: h,
						listeners: i
					}), e && f) {
						var j = d.searchBoxVals[f],
							k = d.searchBoxVals.flightintl_startdate_single || d.searchBoxVals.flightintl_startdate_single1;
						j && k && +k.toDate() >= +(new Date).toDate() && (a.value(j), d.inits.calendar[g].method("setWeek"))
					}
					h.reference && $(h.reference).value().trim().isDate() && a.data("minDate", $(h.reference).value()), d.clearNotice(a[0]), a[0].setAttribute("init_mod", "T")
				})
			},
			register_tab: function(a) {
				var b = this.version.tab;
				$.mod.load("tab", b, function() {
					$(a).regMod("tab", b, {
						options: {
							index: a[0].getAttribute("mod_tab_index") || 0,
							tab: online.first(a[0]).tagName.toLowerCase(),
							panel: a[0].getAttribute("mod_tab_panel"),
							save: !0
						},
						style: {
							tab: a[0].getAttribute("mod_tab_check_class") || "sales_current",
							panel: a[0].getAttribute("mod_tab_class") || {
								display: ["", "none"]
							}
						}
					})
				})
			}
		}
	}), $.ready(function() {
		if (online.util && online.util.RegisterMod && "undefined" == typeof online.registerMod) {
			var a = online.$c("util.RegisterMod");
			"undefined" != typeof __noRegister__ && __noRegister__ || a.register(function() {
				online.validateObj = this.validateObj
			}), online.registerMod = a
		}
	}), online.maskShow = function(a, b, c) {
		if (b = "undefined" == typeof b ? !0 : b, $(a)[b ? "mask" : "unmask"](), b && "undefined" != typeof c) {
			var d = $(a).data("__mask__").maskDiv;
			c.color && (d.style.backgroundColor = c.color), c.opacity && online.css(d, "opacity", c.opacity)
		}
	}, online.create("service.index.SearchHotelService", {
		methods: {
			initialize: function(a) {
				this.info(), this.extend(this, a);
				var b = document.createElement("div");
				b.style.display = "none", b.id = "fl_hotelForm", $("body").append(b), $("#searchHotel").bind("click", function(a) {
					if (a.stop(), window.validateQuery(!0)) {
						var b = {}, c = {
								From: "flightintl_startcity_single",
								To: "flightintl_arrivalcity_single",
								FromTime: "flightintl_startdate_single",
								ToTime: "flightintl_backdate_single"
							};
						for (var d in c)
							if (-1 != d.indexOf("Time")) b[d] = online.registerMod.searchBoxVals[c[d]] || "";
							else {
								var e = online.registerMod.searchBoxVals[c[d]].split("|");
								b[d + "Id"] = e[1], b[d] = e.length > 2 ? e[2].split("，").shift().replace(/@| /g, "").toLowerCase() : "moren"
							}
						var f = (new Date).toDate().addDays(3),
							g = new Date(b.FromTime.replace(/-/g, "/")),
							h = g.addDays(2),
							i = g.addDays(28);
						if (f > g) return online.registerMod.validate($("#ctl00_MainContentPlaceHolder_txtDDatePeriod1"), online.msg.ERROR_FLIGHT[15]), !1;
						if ("" == b.ToTime) return online.registerMod.validate($("#ctl00_MainContentPlaceHolder_txtADatePeriod1"), "gb2312" == online.charset ? "请选择返程日期" : "請選擇返程日期"), !1;
						var j = new Date(b.ToTime.replace(/-/g, "/"));
						if (h > j) return online.registerMod.validate($("#ctl00_MainContentPlaceHolder_txtADatePeriod1"), online.msg.ERROR_FLIGHT[16]), !1;
						if (j > i) return online.registerMod.validate($("#ctl00_MainContentPlaceHolder_txtADatePeriod1"), online.msg.ERROR_FLIGHT[17]), !1;
						b.Children = 0, b.Adults = 2, b["CHD" === $("#ctl00_MainContentPlaceHolder_selUserType").value() ? "Children" : "Adults"] = $("#ctl00_MainContentPlaceHolder_drpQuantity").value();
						var k = "fl_hotelForm_" + +new Date,
							l = ['<form id="' + k + '" action="' + online.siteName.replace("flights", "vacations") + "diy/", ["round", b.From + b.FromId, b.To + b.ToId].join("-") + '" method="post" target="_blank">'];
						for (var m in b) b.hasOwnProperty(m) && l.push('<input type="hidden" name="' + m + '" value="' + b[m] + '" />');
						l.push("</form>"), $("#fl_hotelForm").html(l.join("")), $("#" + k)[0].submit(), $("#fl_hotelForm").html("")
					}
				})
			}
		}
	}), $.ready(function() {
		online.searchWait = online.$c("service.public.SearchWaitService", {
			TIPS_MESSAGER: online.msg.TIPS_MESSAGER
		});
		var a = online.index = online.$c("service.IndexService", {
			searchWait: online.searchWait
		});
		online.$c("service.index.SearchHotelService");
		var b = online.$c("service.public.ValidateService", {
			single: {
				txtDCity: online.$get("txtDCity", !0),
				dest_city_1: online.$get("dest_city_1", !0),
				txtDDatePeriod1: online.$get("txtDDatePeriod1", !0),
				txtADatePeriod1: online.$get("txtADatePeriod1", !0)
			},
			mult: ["#hdn_showflt_ddate", "#hdn_showflt_dcity", "#hdn_showflt_acity"],
			msg: online.msg,
			drpFlightWay: a.drpFlightWay,
			callback: function() {
				var a = $("#txtAirline");
				online.isNull(a[0]) && $("#Airline").value("All"), online.clearNotice(), online.searchWait.afterClick()
			}
		});
		window.validateQuery = function(a) {
			return b.getValidate(a)
		}, a.doQueryString(), online.$c("util.Multipass", {
			target: $("#flight_multiple"),
			addTarget: $("#add_new_line"),
			min: 3,
			template: '            <li online_multipass_index="${index-1}"><span class="line_num">第<em>${index}</em>程 </span>                <label class="flight_item1">                    <span class="important">*</span> ${i18n.startCity}                    <input name="ctl00$MainContentPlaceHolder$txtBeginAddress${index}" mod_change_id="ctl00_MainContentPlaceHolder_txtEndAddress${index-1}" type="text" id="ctl00_MainContentPlaceHolder_txtBeginAddress${index}" autocomplete="off" class="input_text" mod_address_focusnext="true" mod_notice_tip="中文/英文/拼音" {{if index ==1}} mod_save_id="flightintl_startcity_single" mod_save_value="true"{{/if}} mod_address_source="flightintl_start" mod_address_reference="ctl00_MainContentPlaceHolder_txtBeginCityCode${index}" mod="address|notice" mod_address_tpl="address" />                </label>                <label class="flight_item3">                    <span class="important">*</span> ${i18n.endCity}                    <input name="ctl00$MainContentPlaceHolder$txtEndAddress${index}" mod_address_focusnext="true" type="text" id="ctl00_MainContentPlaceHolder_txtEndAddress${index}" mod_next_value="ctl00_MainContentPlaceHolder_txtBeginAddress${index+1}" autocomplete="off"{{if index ==1}} mod_save_value="true" mod_save_id="flightintl_arrivalcity_single"{{/if}} class="input_text" mod_notice_tip="中文/英文/拼音" mod_address_source="flightintl_dest" mod_address_reference="ctl00_MainContentPlaceHolder_txtEndCityCode${index}" mod="address|notice" mod_address_tpl="address" />                </label>                <label class="flight_item4">                    <span class="important">*</span> ${i18n.startDate}                    <input name="ctl00$MainContentPlaceHolder$txtDDatePeriod${index}" type="text" id="ctl00_MainContentPlaceHolder_txtDDatePeriod${index}" class="input_text" mod="calendar|notice" {{if index ==1}}mod_save_value="true" mod_save_id="flightintl_startdate_single"{{/if}}  mod_notice_tip="yyyy-mm-dd" {{if index!=1}} mod_calendar_reference="ctl00_MainContentPlaceHolder_txtDDatePeriod${index-1}" {{/if}} mod_calendar_focusnext="ctl00_MainContentPlaceHolder_txtDDatePeriod${index+1}" autocomplete="off" />                </label>                <a href="javascript:void(0)" class="del_line"  style="{{if index<=2}}display:none{{/if}}">删除</a>                <input name="ctl00$MainContentPlaceHolder$txtBeginCityCode${index}" type="hidden" id="ctl00_MainContentPlaceHolder_txtBeginCityCode${index}">                <input name="ctl00$MainContentPlaceHolder$txtEndCityCode${index}" type="hidden" id="ctl00_MainContentPlaceHolder_txtEndCityCode${index}">            </li>        ',
			addCallback: function(b) {
				b.find("input").bind("keydown", a.keydownByCityInput.bind(this), {
					priority: 13
				}), a.resetCssByXQD()
			},
			removeCallback: function() {
				a.resetCssByXQD()
			}
		}), $("#ctl00_MainContentPlaceHolder_radTypePublic").length > 0 && ($("#ctl00_MainContentPlaceHolder_radTypePublic").bind("click", function() {
			$("#ExpenseType")[0].value = $("#ctl00_MainContentPlaceHolder_radTypePublic")[0].checked ? "PUB" : $("#ExpenseType").value()
		}), $("#ctl00_MainContentPlaceHolder_radTypeOwn").bind("click", function() {
			$("#ExpenseType")[0].value = $("#ctl00_MainContentPlaceHolder_radTypeOwn")[0].checked ? "OWN" : $("#ExpenseType")[0].value
		})), online.registerMod.getFirstCityNameByIp($("#ctl00_MainContentPlaceHolder_txtDCity")), a.voyageType(), window.maskShow = online.maskShow, a.removeCookie("LoginPagePassed", "/", a.domain)
	})
}(cQuery);
