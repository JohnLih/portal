package application

import (
	"encoding/xml"
	"io/ioutil"
	"os"
	"path"
	cmd "portal/base/cmd"
)

func Parsing(name string) (app Application, err error) {
	file := getAppPath(name)
	file += ".xml"
	f, err := os.Open(file)
	if err != nil {
		panic(err)
	}

	x, err := ioutil.ReadAll(f)
	if err != nil {
		//panic(err)
		return app, err
	}

	err = xml.Unmarshal(x, &app)
	if err != nil {
		//panic(err)
		return app, err
	}
	return app, nil
}

func getAppPath(name string) string {
	p := getAppsPath()
	p = path.Join(p, name, name)
	return p
}

func getAppsPath() string {
	p := os.Getenv("PORTAL_HOME")
	p = path.Join(p, "share", "application", "publish")
	return p
}

func Run(name string, app Application) (output string, err error) {

	script := getAppPath(name)
	script += ".cmd"

	envs := []string{}

	for _, opts := range app.Options {
		for _, opt := range opts.Option {
			env := opt.Id + "=" + opt.Text
			envs = append(envs, env)
		}
	}
	return cmd.EnvExectuor(0, envs, script)
}

func GetAppList() (l []string, e error) {
	p := getAppsPath()
	files, err := ioutil.ReadDir(p)
	if err != nil {
		return l, err
	}
	for _, f := range files {
		l = append(l, f.Name())
	}
	return l, nil
}
