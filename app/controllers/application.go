package controllers

import (
	apps "portal/application"
	"strings"

	e "portal/app/error"

	"github.com/revel/revel"
)

type AppController struct {
	*revel.Controller
}

func (a AppController) TempleteList() revel.Result {
	var l, err = apps.GetAppList()
	if err != nil {
		return a.errFunc(err)
	}
	return a.RenderJson(l)
}

func (a AppController) Templete(name string) revel.Result {
	name = strings.ToUpper(name)
	var ap, err = apps.Parsing(name)
	if err != nil {
		return a.errFunc(err)
	}
	return a.RenderJson(ap)
}

func (a AppController) Run(name string, app apps.Application) revel.Result {
	name = strings.ToUpper(name)
	var out, err = apps.Run(name, app)
	if err != nil {
		return a.errFunc(err)
	}
	return a.RenderJson(out)
}

func (a AppController) errFunc(err error) revel.Result {
	revel.ERROR.Println(err)
	var rt = e.PError{Status: 500, Message: "error"}
	return a.RenderJson(rt)
}
