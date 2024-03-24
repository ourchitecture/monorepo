const getContainerLogs = async (execa) => {
    console.log('\nRetrieving ournexus logs...')

    const containerName = `ournexus`

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
        const runArgv = ['logs', containerName]

        const runContainerCommandResult = await execa('docker', runArgv, {
            cleanup: true,
            env: process.env,
            shell: false,
            stderr: process.stderr,
            stdout: process.stdout,
            stripFinalNewline: true,
        })

        if (runContainerCommandResult.failed) {
            throw new Error('Failed to retreive container logs.')
        }
    }

    console.log('Successfully retrieved ournexus logs.')
}

const main = async (argv) => {
    ;(await import('dotenv')).config()

    const execa = (await import('execa')).execa

    await getContainerLogs(execa)
}

;(async () => {
    await main(process.argv.slice(2))
})()
