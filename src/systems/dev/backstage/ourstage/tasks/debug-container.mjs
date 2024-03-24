import buildContainer from './modules/build-container.mjs'

const debugContainer = async (execa) => {
    console.log('\nDebugging ourstage...')

    const ourstageEnv = process.env.OURSTAGE_ENV.toLocaleLowerCase()
    const imageName = `${process.env.OURSTAGE_BACKEND_IMAGE_NAME}-${ourstageEnv}:${process.env.OURSTAGE_BACKEND_IMAGE_TAG}`
    const containerName = `ourstage-backend-${ourstageEnv}`

    const containerIsAlreadyRunningArgv = [
        'ps',
        '--quiet',
        '--filter',
        `name=${containerName}`,
    ]

    const commandOptions = {
        cleanup: true,
        shell: false,
        stripFinalNewline: true,
    }

    const containerIsAlreadyRunningCommandResult = await execa(
        'docker',
        containerIsAlreadyRunningArgv,
        commandOptions
    )

    if (containerIsAlreadyRunningCommandResult.failed) {
        throw new Error('Failed to check if the container was already running.')
    }

    const containerIsAlreadyRunningCommandOutput =
        containerIsAlreadyRunningCommandResult.stdout

    if (
        containerIsAlreadyRunningCommandOutput &&
        containerIsAlreadyRunningCommandOutput.length > 0
    ) {
        console.log('Ourstage is already running at http://localhost:7007.')
        console.log('To debug, run `make stop` and then `make debug`.')
    } else {
        const runArgv = [
            'run',
            '--entrypoint=/bin/bash',
            '--interactive',
            `--name=debug-${containerName}`,
            '--network=host',
            '--rm',
            '--tty',
            '--user=node',
            imageName,
        ]

        const runContainerCommandResult = await execa('docker', runArgv, {
            cleanup: true,
            env: process.env,
            shell: false,
            stderr: process.stderr,
            stdout: process.stdout,
            stripFinalNewline: true,
        })

        if (runContainerCommandResult.failed) {
            throw new Error('Failed to start the container.')
        }
    }

    console.log('Successfully debugged ourstage.')
}

const main = async (argv) => {
    ;(await import('dotenv')).config()

    const execa = (await import('execa')).execa

    await buildContainer(execa)
    await debugContainer(execa)
}

;(async () => {
    await main(process.argv.slice(2))
})()
