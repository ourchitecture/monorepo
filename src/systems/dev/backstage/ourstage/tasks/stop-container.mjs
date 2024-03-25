const stopContainer = async (execa) => {
    console.log('\nStopping ourstage...')

    const ourstageEnv = process.env.OURSTAGE_ENV.toLocaleLowerCase()
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
        const runArgv = ['rm', '--force', containerName]

        const runContainerCommandResult = await execa('docker', runArgv, {
            cleanup: true,
            env: process.env,
            shell: false,
            stderr: process.stderr,
            stdout: process.stdout,
            stripFinalNewline: true,
        })

        if (runContainerCommandResult.failed) {
            throw new Error('Failed to stop the container.')
        }
    }

    console.log('Successfully stopped ourstage.')
}

const main = async (argv) => {
    ;(await import('dotenv')).config()

    const execa = (await import('execa')).execa

    await stopContainer(execa)
}

;(async () => {
    await main(process.argv.slice(2))
})()
