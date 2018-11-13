job "run-powershell" {
  datacenters = ["dc1"]

  type = "batch"

  constraint {
    attribute = "${attr.kernel.name}"
    value     = "windows"
  }

  group "windows" {
    count = 20

    task "1-gethostinfo" {
      driver = "raw_exec"

      config {
        command = "powershell"
        args    = ["get-host"]
      }

      resources {
        memory = 200
        cpu    = 100
      }
    }

    task "2-sleepbecauseisnice" {
      driver = "raw_exec"

      config {
        command = "powershell"
        args    = ["start-sleep -seconds 30"]
      }

      resources {
        memory = 100
        cpu    = 100
      }
    }

    task "3-printfile" {
      driver = "raw_exec"

      config {
        command = "C:\\Windows\\System32\\cmd.exe"
        args    = ["/c", "type", "c:\\target\\myfile.txt"]
      }

      resources {
        memory = 100
        cpu    = 100
      }
    }
  }
}

