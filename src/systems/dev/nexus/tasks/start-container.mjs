import buildContainer from './modules/build-container.mjs'
import buildStorageVolume from './modules/create-storage-volume.mjs'

const startContainer = async (execa) => {
    console.log('\nStarting ournexus...')

    const imageName = `${process.env.OURNEXUS_IMAGE_NAME}:${process.env.OURNEXUS_IMAGE_TAG}`
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
        console.log('Ournexus is already running at http://localhost:8081.')
    } else {
        const runArgv = [
            'run',
            '--detach',
            `--name=${containerName}`,
            '--network=host',
            '--user=nexus',
            '--volume=ournexus-data:/nexus-data',
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

        console.log('Ournexus is running at http://localhost:8081.')
    }

    console.log('Successfully started ournexus.')
}

const main = async (argv) => {
    ;(await import('dotenv')).config()

    const execa = (await import('execa')).execa

    await buildStorageVolume(execa)
    await buildContainer(execa)
    await startContainer(execa)
}

;(async () => {
    await main(process.argv.slice(2))
})()
