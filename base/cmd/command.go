package cmd

import (
	"bytes"
	"os"
	"os/exec"
	"time"
)

func Exectuor(command string, args ...string) (output string, err error) {
	cmd := exec.Command(command, args...)
	out, err := cmd.CombinedOutput()
	if out != nil {
		output = string(out)
	}
	return output, err
}

func TimerExectuor(limit time.Duration, command string, args ...string) (output string, err error) {
	return EnvExectuor(limit, nil, command, args...)
}

func EnvExectuor(limit time.Duration, envs []string, command string, args ...string) (output string, err error) {
	cmd := exec.Command(command, args...)
	out := &bytes.Buffer{}
	cmd.Stdout = out
	if envs != nil {
		env := os.Environ()
		env = append(env, envs...)
		cmd.Env = env
	}

	err = cmd.Start()
	if err != nil {
		return "", err
	}

	if limit != 0 {
		timer := time.NewTimer(time.Second * limit)
		go func(timer *time.Timer, cmd *exec.Cmd) {
			for _ = range timer.C {
				if cmd.ProcessState.Exited() {
					err = cmd.Process.Kill()
				}
			}
		}(timer, cmd)
	}

	cmd.Wait()

	return string(out.Bytes()), err
}
