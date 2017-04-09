package cmd

import (
	"fmt"
	"os/exec"
	"testing"
)

func print(out string, err error) {
	fmt.Println("out = " + out)
	if err != nil {
		fmt.Println("err = " + err.Error())
	}
}

func TestExectuor(t *testing.T) {
	out, err := Exectuor("ping", "127.0.0.1", "-c 3")
	print(out, err)
}

func TestEnvExectuor(t *testing.T) {
	envs := []string{"env1=1", "env2=2"}
	out, err := EnvExectuor(10, envs, "echo", "$env1", "$env2", "$HOME")
	print(out, err)
}

func TestCommand(t *testing.T) {
	cmd := exec.Command("echo", "$HOME")
	out, err := cmd.CombinedOutput()
	print(string(out), err)
}
