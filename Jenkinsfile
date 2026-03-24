pipeline {
  agent any

  options {
    timestamps()
    disableConcurrentBuilds()
  }

  environment {
    IMAGE_NAME = "my-devsecops-practice:local"
  }

  stages {
    stage('Checkout') {
      steps {
        deleteDir()
        checkout scm
        sh '''
          echo "PWD:"
          pwd

          echo "Workspace files:"
          ls -la

          echo "Tracked files:"
          git ls-files || true

          echo "Current commit:"
          git rev-parse HEAD || true

          if [ -f .gitleaks.toml ]; then
            echo ".gitleaks.toml exists"
            cat .gitleaks.toml
          else
            echo ".gitleaks.toml is missing"
          fi
        '''
      }
    }

    stage('Secrets Scan - Gitleaks') {
      steps {
        sh '''
          docker run --rm \
            -v "$WORKSPACE:/repo" \
            zricethezav/gitleaks:latest detect \
            --no-git \
            --source=/repo \
            --exit-code 1
        '''
      }
    }

    stage('SAST - Semgrep') {
      steps {
        sh '''
          docker run --rm \
            -v "$WORKSPACE:/src" \
            semgrep/semgrep:latest semgrep scan \
            --config=p/owasp-top-ten \
            --config=p/secrets \
            --error /src
        '''
      }
    }

    stage('IaC / Dockerfile Scan - Checkov') {
      steps {
        sh '''
          docker run --rm \
            -v "$WORKSPACE:/tf" \
            bridgecrew/checkov:latest \
            -d /tf --config-file /tf/checkov.yaml
        '''
      }
    }

    stage('Dockerfile Lint - Hadolint') {
      steps {
        sh '''
          docker run --rm -i hadolint/hadolint < Dockerfile
        '''
      }
    }

    stage('Build Image') {
      steps {
        sh '''
          docker build -t $IMAGE_NAME .
        '''
      }
    }

    stage('Container Scan - Trivy') {
      steps {
        sh '''
          docker run --rm \
            -v /var/run/docker.sock:/var/run/docker.sock \
            aquasec/trivy:latest image \
            --exit-code 1 \
            --severity CRITICAL,HIGH \
            $IMAGE_NAME
        '''
      }
    }
  }

  post {
    success {
      echo 'Pipeline passed'
    }
    failure {
      echo 'Pipeline failed'
    }
  }
}