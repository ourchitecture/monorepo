import buildContainer from './modules/build-container.mjs'

const startContainer = async (execa) => {
    console.log('\nStarting ourstage...')

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
    } else {
        const runArgv = [
            'run',
            '--detach',
            `--name=${containerName}`,
            '--network=host',
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

        console.log('Ourstage is running at http://localhost:7007.')
    }

    console.log('Successfully started ourstage.')
}

const main = async (argv) => {
    ;(await import('dotenv')).config()

    const execa = (await import('execa')).execa

    await buildContainer(execa)
    await startContainer(execa)
}

;(async () => {
    await main(process.argv.slice(2))
})()
