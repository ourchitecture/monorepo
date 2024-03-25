const main = async () => {
    require('dotenv').config()

    const glob = (await import('glob')).glob
    const execa = (await import('execa')).execa

    console.log('Installing ourstage python dependencies...')

    const pythonCommand = process.env.PYTHON3
    const pipIndexUrl = process.env.PIP_INDEX_URL

    const upgradePipArgv = [
        '-m',
        'pip',
        'install',
        '--index-url',
        pipIndexUrl,
        '--upgrade',
        'pip',
    ]

    const upgradePipResult = await execa(pythonCommand, upgradePipArgv, {
        cleanup: true,
        env: process.env,
        shell: false,
        stderr: process.stderr,
        stdout: process.stdout,
        stripFinalNewline: true,
    })

    if (upgradePipResult.failed) {
        throw new Error('Failed to upgrade pip.')
    }

    const pipInstallDependenciesArgv = [
        '-m',
        'pip',
        'install',
        '--index-url',
        `"${pipIndexUrl}"`,
        '--requirement',
        './techdocs.requirements.txt',
    ]

    const pipInstallDependenciesResult = await execa(
        pythonCommand,
        pipInstallDependenciesArgv,
        {
            cleanup: true,
            env: process.env,
            shell: false,
            stderr: process.stderr,
            stdout: process.stdout,
            stripFinalNewline: true,
        }
    )

    if (pipInstallDependenciesResult.failed) {
        throw new Error('Failed to install python dependencies.')
    }

    console.log('Successfully installed ourstage python dependencies.')
}

;(async () => {
    await main()
})()
