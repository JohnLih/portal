package cmd

import (
	"time"

	"github.com/codeskyblue/go-sh"
)

type Exectuor struct {
	Envs    map[string]string
	Timeout time.Duration
	Cmd     []string
	Dir     string
}

func (exe *Exectuor) Run() (output string, err error) {
	session := sh.NewSession()

	exe.setDir(session)

	exe.setTimeout(session)

	exe.setEnvs(session)

	cmd := exe.Cmd
	session.Command(cmd[0], cmd[1:])
	out, err := session.Output()

	if err != nil {
		return "", err
	}

	return string(out), err
}

func (exe *Exectuor) setDir(session *sh.Session) {
	if exe.Dir != "" {
		session.SetDir(exe.Dir)
	}
}

func (exe *Exectuor) setTimeout(session *sh.Session) {
	if exe.Timeout > 0 {
		session.SetTimeout(exe.Timeout)
	}
}

func (exe *Exectuor) setEnvs(session *sh.Session) {
	if exe.Envs != nil {
		for key, val := range exe.Envs {
			session.SetEnv(key, val)
		}
	}
}
